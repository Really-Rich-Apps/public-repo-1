#!/usr/local/bin/rexx
/*

 Football Pool - Jeff Sommer

*/
/*qstr='env'('|grep "QUERY_STRING"')
  parse var qstr +0 "STRING=" in */

in=getenv("QUERY_STRING")

week=linein('week')
now='date'()
now=word(now,1) word(now,2) word(now,3) word(now,4)

say "Content-type: text/html"
say

ex=linein('/football/exp')
tt=time('n')
parse var tt hh ":" mm ":" .
exnow=date('s')||hh||mm

if length(in)=0 then
do
	if exnow>ex then signal toolate

	ext=substr(ex,5,2)||"/"substr(ex,7,2)||"/"||substr(ex,1,4)||" "||substr(ex,9,2)||":"||substr(ex,11,2)
	exnt=substr(exnow,5,2)||"/"substr(exnow,7,2)||"/"||substr(exnow,1,4)||" "||substr(exnow,9,2)||":"||substr(exnow,11,2)

	say "<html><head><title>Football for week" week"</title></head>"
	say "<body><h1><center>Football!</center></h1>"
	say "<center><table border='2'><tr><td bgcolor='khaki' align='center' width='400'>Welcome to the H&A football system!  Additional introductory text will go here...</td></tr></table></center>"
	say "<center><table border='2'><tr><td bgcolor='aliceblue' align='center' width='350'>Picks must be submitted by<br><tt>"||ext||"</tt>."
	say "<hr>The current system time is<br><tt>"||exnt||"</tt>.</td></tr></table></center>"
	say "<center><table border='2'><tr><td bgcolor='wheat' align='center' width='300'><b>LINKS:</b>"
	say "<br><a href='1?f=request'>SignUp</a> | <a href='1?f=standings'>H&amp;A Standings</a> | <a href='1?f=about'>About</a><br><a href='http://sports.yahoo.com/nfl/standings.html' target='voo'>League Standings</a></td></tr></table></center>"
	say '<FORM METHOD="GET" ACTION="1">'
	say '<input type="hidden" name="f" value="pix">'
	say "<hr>1. Select your designation: (Don't have one? Click <a href='1?f=request'>here</a>.)<P>"
	say "<table border='0'><tr>"
	a=1
	flag=0
	do while flag=0
		n=linein("players")
		if length(n)=0 then flag=1
		else 
		do
			parse var n n '\' .
			say '<td width="125"><INPUT TYPE="RADIO" NAME="u" VALUE="'||n||'">'||n||"</td>"
			if a%4 = a/4 then say "</tr><tr>"
			a=a+1
		end
	end
	say "</tr></table>"

	say "<hr>2. Enter your password: &nbsp;<input type='password' length='10' name='pw'>"

	say "<hr>3. Select your picks:<P>"
	say '<table border="1">'
	say '<caption>Week' week'</caption>'
	flag=0
	a=1
	do while flag=0
		n=linein(week||".sched")
		if length(n)=0 then flag=1
		else
		do
			parse var n with +0 g1 "," g2
			say '<tr><td><input type="radio" name="g'||a||'" value="'||g1||'">'||g1
			say '<td><input type="radio" name="g'||a||'" value="'||g2||'">'||g2
			a=a+1
		end
	end
	say "</table>"
	say '<HR>4. Press this button:&nbsp;&nbsp;<input type="submit" value="Make it so!">'

	say "</form>"
	say "<hr>"
	say '<p><center><img src="/i/notepad.gif" alt="Notepad rocks!"></center></p>'
	say "</body></html>"
end
else
do
	parse var in with +0 . "=" f "&u=" u "&pw=" pw "&" rest

	if f="pix" then
	do
		if exnow>ex then signal toolate
		f2='/football/pix/'||week||'.'||u||'.html'
		if getpw(u)^=pw then signal pwerr
		say "<html><body>Thanks for your picks, " u"."
		x='echo'('"<html><p>Hello,' u'.<p>Here are your picks for week' week'.<p>Your picks were submitted <tt>'now'</tt>.">'||f2)
		say "<HR>Here are your picks.  You can print this page out, if you like..."
		flag=0
		file='/football/pix/'||week||'.'||u
		say '<ul>'
		pickstr=now
		do while flag=0
			parse var rest with +0 "=" w "&" rest
			if length(rest)=0 then flag=1
			ww=translate(w,'+',' ')
			wo=opp(w)
			say "<li><b>"ww"</b> ("wo")"
			x='echo'('"<p><b>'ww'</b> ('wo')">>'||f2) 
			pickstr=pickstr w
		end
		cmd='"'||pickstr||'">'||file
		say "</ul>"
		x='echo'(cmd)
		x='echo'('"</html>">>'||f2)
		flag=0
		do while flag=0
			n=linein('players')
			if length(n)=0 then flag=1
			parse var n n '\' . '\' m
			if n=u & length(m)>0 then
			do
				say "<P>These picks will be sent to email address <tt>"m"</tt>"
		x='cat'(f2||'|mail -s"Your picks for week' week'"' m)
			end
		end
		say "</body></html>"
	end

	if f="about" then
	do
		flag=0
		do while flag=0
		n=linein('about.html')
		if length(n)=0 then flag =1
		else say n
		end
	end

	if f="remind" then
	do
		say "<html><body><h1>Reminding...</h1>"
		pickt='ls'('/football/pix/'||week||'.*')
		ex=linein('/football/exp')
		ext=substr(ex,5,2)||"/"substr(ex,7,2)||"/"||substr(ex,1,4)||" "||substr(ex,9,2)||":"||substr(ex,11,2)
		flag=0
		do while flag=0
			n=linein('/football/players')
			if length(n)=0 then
				flag =1
			else
			do
				parse var n n "\" p "\" e
				if pos(n,pickt)>0 then
				do
					say "<p>"||n "has picked"
				end
				else
				do
					say "<P>"||n "has NOT picked.  sending email to" e
					msg="Attention," n||"!  You have not made your football picks yet.  Time is running out.  Picks must be submitted by" ext||".  Surf on over to http://spork.heinzassoc.com to make your selections NOW!"
					x='echo'('"'||msg||'"|mail -s"Reminder" '||e)
				end
			end
		end
		say "<p><B>Finished</b></body></html>"
	end

	if f="standings" then
	do
		flag=0
		do while flag=0
		n=linein('standings.html')
		if length(n)=0 then flag =1
		else say n
		end
	end

	if f="request" then
	do
		flag=0
		do while flag=0
		n=linein('request.html')
		if length(n)=0 then flag =1
		else say n
		end
	end

	if left(f,8)="request2" then
	do
		parse var in . "n=" n "&" .
		parse var in . "pw=" pw "&" .
		parse var in . "e=" e .
		say '<html><body><p>Thanks for signing up, 'n'. You are now activated on the system.'
		say "<p>Your password is <tt>"pw"</tt>.</p>"
		if length(e)>0 then say '<p>Your picks will be sent to <tt>'e'</tt>.'
		else say '<P>You will not be contacted via email.'
		say '<form action="1"><input type="submit" value="Back to main screen"></form>'
		say '</body></html>'
		'echo'(n'\\'pw'\\'e'>>players')
	end

	if f="admin" then
	do
		say "<html><body><h1>Greetings, Administrator!</h1>"
		say "<P>Enter the final results for week" week"."
		say '<form action="1" method="get">'
		say '<input type="hidden" value="admin2" name="f">'
		say "Enter next week's identifier:"
		say '<input type="text" name="w" size="3" value="'week+1'">'
		say "<P>Enter next week's expriation:<br>Format is <tt>"
		say 'YYYYMMDDHHMM</tt> <i>with</i> leading zeroes and 24-hour hours (no AM/PM).'
		say '<input type="text" name="ex" size="13" value="">'
		flag=0
		say '<table border="1">'
		a=1
		do while flag=0
			n=linein(week||".sched")
			if length(n)=0 then flag=1
			else
			do
				parse var n with +0 g1 "," g2
				say '<tr><td><input type="radio" name="g'||a||'" value="'||g1||'">'||g1
				say '<td><input type="radio" name="g'||a||'" value="'||g2||'">'||g2
				a=a+1
			end
		end
		say "</table>"
		say '<p><input type="submit"></form>'
		say "</body></html>"
	end

	if left(f,6)="admin2" then
	do
		parse var in . "&w=" neww "&ex=" exnnn "&" rest
		flag=0
		file='/football/results/'||week||'.Results'
		pickstr=""
		do while flag=0
			parse var rest with +0 "=" w "&" rest
			if length(rest)=0 then flag=1
			/*say "<p>"w*/
			pickstr=pickstr w
		end
		cmd='"'||pickstr||'">'||file
		x='echo'(cmd)
		cmd='"'||neww||'">/football/week'
		x='echo'(cmd)
		cmd='"'||exnnn||'">/football/exp'
		x='echo'(cmd)
		say "<p>OK"

		fin=linein('/football/results/'week'.Results')
		plflag=0
		do while plflag=0
			n=linein('/football/players')
			if length(n)=0 then plflag=1
			else
			do
				parse var n n "\" . "\" z

				f2='/football/pix/'week'.'n
				tmp='/football/f'(f2)
				if tmp='no' then p=''
				else p=linein(f2)

				ps=0
				do a=1 to words(fin)
					if wordpos(word(fin,a),p)>0 then ps=ps+1
				end
				say "<p>"n "got" ps "points"
				if length(z)>0 then do
					x='echo'('"'n': Football results are in!  You got' ps 'points.  Check it out at http://spork.heinzassoc.com/football/1?f=standings right now!"|mail -s"Standings: week' week'" 'z)
				end
				cmd='"'n','ps'">>/football/points/'week'.Points'
				x='echo'(cmd)
			end
		end
		say "<P>this week complete..."

		say "<P>Recalculating totals..."
		name.=""
		tot.=""
		c=0
		files='ls'('/football/points')
		do a=1 to words(files)
			fi="/football/points/"||word(files,a)
			flag=0
			do while flag=0
				n=linein(fi)
				if length(n)=0 then flag=1
				else
				do
					parse var n n1 "," p1
					found=0
					d=0
					do b=1 to c
						if name.b=n1 then
						do
							found=1
							d=b
						end
					end
					if found=0 then
					do
						c=c+1
						name.c=n1
						tot.c=p1
					end
					else
					do
						tot.d=tot.d+p1
					end
				end
			end
		end /* do a=1 to words(files) */
		x='echo'('"'||name.1||','||tot.1||'">/football/standings')
		do a=2 to c
			x='echo'('"'||name.a||','||tot.a||'">>/football/standings')
		end
		say "<P>calculated!!!!!  SWEET!!!"

		x='echo'('"<HTML>">/football/standings.html')
		l.1="<HEAD><TITLE>Standings (week" week")</TITLE></HEAD>"
		l.2="<BODY><H1>Standings as of week" week"</h1>"
		l.3="<table border=0>"
		l.4="<caption>Totals</capton>"

		do a=1 to 4
			x='echo'('"'||l.a||'">>/football/standings.html')
		end
		stretch=trunc(500/(week*15))
		flag=0
		do while flag=0
			n=linein('/football/standings')
			if length(n)=0 then flag=1
			else
			do
				parse var n n1 "," p1
l="<tr><td>"n1"</td><td><img src='/i/red.gif' height='12' width='"p1*stretch"' alt='"p1"'></td><td>"p1"</td></tr>"
				x='echo'('"'l'">>/football/standings.html')
			end
		end
		x='echo'('"</table>">>/football/standings.html')
		l.10="<p><hr>Individual results from week" week
		l.11="<table border=0>"
		do a=10 to 11
			x='echo'('"'||l.a||'">>/football/standings.html')
		end
		close(fi)
		stretch2=20
		flag=0
		do while flag=0
			n=linein(fi)
			if length(n)=0 then flag=1
			else
			do
				parse var n n1 "," p1
l="<tr><td>"n1"</td><td><img src='/i/blue.gif' height='12' width='"p1*stretch2"' alt='"p1"'></td><td>"p1"</td></tr>"
				x='echo'('"'l'">>/football/standings.html')
			end
		end
		sss="</table><a href='http://spork.heinzassoc.com/football/1'>Back to main screen</a>"
		x='echo'('"'||sss||'">>/football/standings.html')
		x='echo'('"</body></html>">>/football/standings.html')
		say "<p>Wrote new <tt>standings.html</tt>"
	end /* f=admin2 */
end /* query string = something */
exit

opp: parse arg team
r="???"
team=translate(team,"+"," ")
flay=0
f="/football/"||week||".sched"
close(f)
do while flay=0
	n=linein(f)
	if length(n)=0 then flay=1
	else
	do
		parse var n a "," b
		if a=team then r=b
		if b=team then r=a
	end
end
close(f)
return r

getpw: parse arg un
f="/football/players"
close(f)
r="???"
flay=0
do while flay=0
	n=linein(f)
	if length(n)=0 then flay=1
	else
	do
		parse var n uu "\" nn "\" .
		if (un=uu) then r=nn
	end
end
close(f)
return r

pwerr:
say "<html><body><h1>PASSWORD INCORRECT!</h1>"
say "<p>You entered the wrong password.  Passwords <b>are</b> case sensitive."
say '<p><a href="javascript:history.back()">Oops!</a>'
say "</body></html>"
exit

toolate:
say "<html><body><h1>TOO LATE!</h1>"
say "<p>Games have already started for this weekend.  You can't make"
say "picks.  Try to get here a little sooner next time..."
say "<P><a href='http://www.lozer.com'>OK</a>"
exit
