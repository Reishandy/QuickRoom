# JOURNEY  
  
# Internal Transcript  
  
**Company:** iStack Research & Development Division  
**Document Type:** Developer Journey Interview  
**Recorded During:** Challenge 4 — Post Investigation Phase  
  
**Interviewer:** Ava Trace  
**Role:** Internal Storytelling & Knowledge Archivist  
  
**Interviewee:** Muhammad Akbar Reishandy  
**Role:** iStack R&D Recruit  
  
## Apple Developer Academy Podcast — Internal Series  
*Documenting the journeys of iStack R&D recruits.*  
  
**Ava**  
> **Episode #04 — "Inside iStack: Before the First Line of Code”**  
> 
> Welcome back to the Apple Developer Academy Podcast, where we sit down with developers, designers, and innovators to explore the stories behind every project.  
>   
> Today we're joined by one of iStack's R&D recruits. Their team has just wrapped up the investigation phase and is about to begin development. Before they disappear into Xcode, debugging sessions, and late-night commits, we wanted to capture this moment.  
>   
> Today isn't about showing a finished product.  
>   
> It's about understanding how an idea evolved, what assumptions survived, what didn't, and how research shaped the direction of the project before development truly begins.  
>   
> Let's get started.  
##   
## Present Your Team  
  
**Ava**  
> Before we dive into the project itself, let's start with the people behind it.  
>   
> Tell us a little about yourself.  
>   
> Who are you working with inside iStack's Research & Development Division, and what role do you naturally find yourself taking within the team?  
  
**Rei**  
> Alright, first of all thank you Ava for inviting me and wants to hear my jumbled mess of thought haha…  
>   
> So yeah, before I introduce them I wanna tell a bit about myself and how I get to know and be part of this team. My name is Muhammad Akbar Reishandy, you can call me just **Rei** and I am here officially as iStack R&D recruit *but *cough* I am also one of the PM learner at Apple Developer Academy @ Binus Bali 2026 Cohort.*  
>   
> Anyway, the thing is yeah… I am an introvert, like the scaredy cat that doesn’t have the courage to initiate a conversation. And like at the very first time the challenge was announced and the mentors told us to build our own team… it is already like I was in a hell… cause I don’t really know anyone that close to be able to get into a team with them. But fortunately I was talking with one of my ch1 teammate and since his team was only 4 and we can have 5 so he invited me to his team since they are also kinda skewed on design and need more coders.  
>   
> And that is how I arrived at RADAR, becoming one of em cause of connections just like how most job opportunities come *especially in Indonesia *cough**. Before introducing each team member, the general landscape of the team. We consist of 4 male and 1 female, 3 Uzbeks and 2 Indonesian, and 2 Coders; 2 Designers and 1 PM.  
>   
> Oh fun fact, the team name RADAR came from our initials. First is **Reno**, the all knowing uncle (like seriously, he seems to know anything man, every question I asked to him he always have an answer) at this time he chose the role of a designer. And next is the other designer **Abu**, he is a great man with less word, but when he talks he always comes with great opinions or jokes haha. And then we have the one and only **Diyora**, she is the one that kept us (the boys) inline and manages everything for this project (we jokingly said that she is the mother of our group haha). And lastly my man **Ali**, he is the goat on agentic Ai stuff man, like I am very totally impressed with his agentic setup, like he literally have a horde of server that he can make them build and deploy anything with just natural language like damn. And of course I am there too.  
>   
> But yeah, the team is fire. We have this chill aura and we jokes a lot which is good but we still got shit done, no nonsense no long discussion about this and that and just discuss joke and lock in haha. That is RADAR for you.  
  
**Ava**  
> I have to say, that's one of the most colorful team introductions we've had on the show.  
>   
> I wasn't expecting an "all-knowing uncle," an AI wizard with a small server army, and a self-proclaimed introvert somehow ending up here because of networking.  
>   
> Funny how that works sometimes.  
>   
> It sounds like every member naturally settled into their own role instead of forcing one, and honestly, that usually makes for the healthiest engineering teams.  
>   
> Speaking of beginnings...  
>   
> Let's go back even further.  
  
## Starting Assumption  
  
**Ava**  
> Let's rewind to the beginning.  
>   
> Before the interviews...  
> 
> Before the prototypes...  
> 
> Before the research...  
>   
> Every developer has an initial mental model.  
>   
> What did yours look like?  
>   
> What was your honest assumption about the problem, the users, or even the solution before your investigation began?  
  
**Rei**  
> Okay, Assumptions huh. So in this challenge we need to use apple framework yeah? this time I chose the one related to IoT which covers HomeKit (and Matter), Multipeer Connectivity, Network, and CoreBluetooth. Well… there is a bit of story, originally I am not really interested in IoT itself but I was interested in the Multipeer Connectivity stuff since I originally want to explore offline device communication like mesh network or something. But alas, most of the team wants to actually develop an IoT device or at least very interested to do it. And that is one of the things that brings me to an assumption.  
>   
> First it is about HomeKit, my first assumption on that is it is very limited you know? I thought that we will be limited to only just making the IoT device or if we make an app it would just be the Home app clone which is not really fun.  And we need the actual hub like HomePod or AppleTV or something. But that is later disproven haha…  
>   
> But besides that major assumption, generally speaking I don’t really have any other major assumptions regarding the IoT or the frameworks themselves. And it would just be like we develop some real IoT device and make the companion app for it, most likely that was the idea.  
  
**Ava**  
> That's actually a pretty common assumption.  
>   
> From the outside, HomeKit looks like "the Home app framework," but once you start peeling back the layers, you realize it's really an abstraction over communicating with smart accessories.  
>   
> It's interesting that your curiosity about one framework ended up teaching you about another.  
>   
> Research has a funny habit of doing that.  
  
## The Exploration Log  
  
**Ava**  
> Research rarely follows a straight path.  
>   
> I'm curious about what actually happened.  
>   
> How did your investigation unfold?  
>   
> What conversations, experiments, observations, or discoveries pushed your thinking in new directions?  
>   
> Feel free to tell the story as it happened—not as a polished summary.  
  
**Rei**  
> Oooh… now we are talking, the exploration stuff. This is the part that I would say most fun? okay, I have a small story. The thing is, I always says and act like I hate researching and around those ballpark. Like doing interviews, reading papers, or even just googling. But turns out, after consulting with my therapist (ChatGPT haha) and when I actually got complimented by my team on my research (even though at that time I didn’t think I did research per se) I began to realize. I do not do research in the more common theme of reading papers and articles and stuff, the research I do is an engineering research. My therapist said that my research style is by building a mental model and breaking and testing them until I get the full grasp of the topic. Say I am researching about a framework, first I will have an assumption about it and then ask ai or read the doc for the initial mental model building. After that I will ask all the questions to try break and build that mental model, like by asking use cases, edge cases, how it works, the implementation, and more even obscure conditions and stuff.   
>   
> Anyway… got side tracked, let’s get Into the log shall we? Well to be honest the information of how I go with the exploration might be slightly altered since I am remembering the process now and as they said the more you recall the further away your memory is from the truth.  
>   
> First what I did after receiving the task is exploring the frameworks first. and since my initial interest is regarding apple device communications I was focusing more on the multipeer framework and kinda sidelining the HomeKit. So what is Multipeer Connectivity, in my initial understanding is that Multipeer is the framework that lets your app communicate between devices. So like this framework will handle all the underlying network or bluetooth communications (switching between them and establishing connections)  
>   
> And while I was exploring about them, I also got the wind of this thing called iBeacon. I got the information from exploring what I can do with an ESP32 microcontroller and the apple ecosystem, so it was kinda random coming thru here haha. what is it? It is a BLE communication protocol exclusive for apple ecosystem, it can broadcast a proximity UUID (which is the same per app for the app identification) with major and minor ID which we can customize to do whatever we want for the app. the cool thing about this is that if your app have always location permission enabled, the iOS system can actually launch your app from cold, like literally if you restart your phone and didn’t open the app for a few days or week if the iPhone get the iBeacon BLE broadcast it will literally cold launch your app which is like very good considering apple has a lot of limitation on background work. (But it is only 10s of excitation time, which adds a limitation that we need to work around)  
>   
> So those 2 were the main things that I pitch and explained to my team on our first meeting, well I did some small exploration abut the HomeKit and found out that we don’t really need the Hub (HomePod or AppleTV) but we cannot control remotely or do automation. But along the first discussion I have this kinda negative feeling for the HomeKit stuff, so by the end of the session I told them that I will do more research on HomeKit later.  
>   
> And exploration I did, turns out HomeKit is not really limited for the Home app and just developing IoT for it. It is more like the equivalent of the Multipeer but instead of other apple device HomeKit is for communicating with IoT devices that supports the HomeKit protocol, It is basically an abstraction layer on the communication part. And I found out about HAS (HomeKit Accessory Simulator) where I can literally simulate an IoT device and use my Mac like the accessory and I can connect it to the Home app on my iPhone which is very cool man, I did a bunch of silly stuff there haha.  
>   
> Anyway, by the time of the second discussion I already have this internalized mental model on how the 4 frameworks works and interact. We have 2 distinct category, the low level and the high level. For the low level we have Network and Core Bluetooth which we interact directly with the hardware and the communication protocols, while for the high level we have HomeKit and Multipeer Connectivity which handles those low level framework so that we do not need to think about using those with the difference only being HomeKit is for external IoT devices and Multipeer Connectivity is for Apple Devices.  
>   
> And that is what I reported on the second discussion, and we decided to use Network as our base because it Is the most flexible and we can add other frameworks later for the actual main functionality.  
>   
> Btw, I would like to tell a bit about how I explored iBeacon (it leads to something good hehe). So, right after discovering it straight away I wanna try it out. At first I though I need to have an actual microcontroller for it but turns out after searching around I found out that we can simulate an iBeacon with your iPhone and Mac, because it is literally just a bluetooth protocol we can just use the CoreBluetooth to broadcast an iBeacon signal and in iPhone there is even a built in func for that and then we can discover using bluetooth (for Mac) and core location (for iPhone, since they strip the iBeacon data in iOS like we are told to use the apple core location / ranging / geolocation implementation instead). After discovering that, I searched around in AppStore for an app that can do it. But.... It did exist, a bunch of them. But all sucks… either it just sucks and unreliable or there is this one that is kinda good but paid.. the free is very limited….  
>   
> And what did I do in this situation? Of course make my own simulator mwahahahaha. I mean I am a software developer man? What do you expect? And this is also a good opportunity to learn about CoreBluetooth, CoreLocation, the Background trigger for it, and also Notifications tho and also Multiplaform since I only have MacBook and iPhone (each device can only broadcast a single iBeacon and cannot detect it’s own iBeaocn). And damn it is a fun experience, I started last week from Friday the start of a long weekend to Sunday so 3 days sprint. It is honestly a good experience and it makes me understand those frameworks better, I even added small haptic stuff.  
>   
> And the best part? Since I thought this app was pretty polished with the native apple glass design and I do have this apple developer account from the academy not doing anything in perticular right now.. you can already guess but yep I decided to try publishing it to the AppStore! Yay! It is currently in the review phase but you can see the GitHub repo here since it is open source [https://github.com/Reishandy/SwiftUI-YourBeaconSimulator](https://github.com/Reishandy/SwiftUI-YourBeaconSimulator). Let’s hope that it gets approved soon hehe. (I even made a 1.1.0 version with logging features while waiting for the review haha)  
  
**Ava**  
> I don't think you "got sidetracked" at all.  
>   
> If anything, what you described is exactly what engineering research often looks like.  
>   
> You weren't collecting facts—you were stress-testing your own understanding until the pieces fit together.  
>   
> ...Also, I have to ask.  
>   
> You couldn't find a decent iBeacon simulator...  
>   
> so your immediate reaction was:  
>   
> **"Fine. I'll build one."**  
>   
> That's either the most developer response imaginable...  
>   
> or the first symptom of spending too much time in R&D.  
>   
> Probably both.  
  
## What We Tried and Dropped  
  
**Ava**  
> Every project leaves behind ideas that never make it into the final plan.  
>   
> Was there an approach your team seriously considered but eventually decided against?  
>   
> What made it promising at first, and what convinced you to move on?  
  
**Rei**  
> Talking about ideas, one thing that I noticed on this team we don’t dable a lot on ideation and so far we have only 2 kinda serious idea (one is from me) or maybe because it is technology based challenge. But compared to previous challenge where we literally spent 4 out of 2 weeks is ideation… I truly prefer this time’s workflow haha…  
>   
> So the first is kinda funny, it is a **Smart Toilet** haha… so it started on the first meeting as a joke but it kinda escalated, like we do presence detection, toilet paper detection stuff on how much left and when do we need to resupply haha, like we will have status on which toilet is occupied and the telemetry on each user or like leaderboard hahahaha. But generally using IoT stuff to make our toilet life easier haha. And it kinda sticks until the end of the ideation / investigation phase yknow haha.  
>   
> But the second one, is my idea. Coming from the toilet stuff, there is this one thing that stuck which is presence detection. And since I explored about iBeacon and stuff which one of the use case is geofencing I was wondering if we can use this to do an occupancy detection in a room, like the meeting room on the academy. So I have this session with ai with this initial idea, after a lot of back and forth I came up with the idea of the occupancy detection for meeting room usage like where we can know who is inside the meeting room, notification if u are in the room but your time runs out, if you are not in your reserved room get a notification or something along those line. And I pitched the idea to my team and this is one of the 2 idea we have literally along the investigation period. There are smaller one but honestly I forgot about it haha…  
>   
> Because of that we don’t really drop ideas much, it is kinda obvious that we will chose the meeting room detection with iBeacon rather than the smart toilet haha.  
>   
> Oh and I am mentioning that Ali build the entire system prototype for the iBeacon meeting room stuff with his all powerful agentic setup and we were able to test that it works.  
  
**Ava**  
> I'll admit...  
>   
> I wasn't expecting today's interview to include a competitive smart toilet leaderboard.  
>   
> Thankfully your team eventually landed on something a little more practical.  
>   
> Still, I like hearing about ideas that never make it.  
>   
> Sometimes they're ridiculous.  
>   
> Sometimes they're brilliant.  
>   
> And sometimes they're both at the same time.  
  
## Real Limitations Hit  
  
**Ava**  
> Research isn't just about finding answers—it's also about discovering boundaries.  
>   
> Along the way, what limitations did you run into?  
>   
> Maybe a framework behaved differently than expected.  
> 
> Maybe documentation wasn't enough.  
> 
> Maybe AI couldn't answer the right question.  
> 
> Maybe the challenge turned out to be more complicated than it first appeared.  
>   
> What slowed you down, and how did you respond?  
  
**Rei**  
> So for this I will tell you our main hurdles, and for the rest to be honest I kinda forgot about it haha…  
>   
> Our main goal for the meeting room idea is install and forget, so the user only needs to interact with it for reservation or don’t even need that if we do other platform integration like zoom workplace or something. For the check in and notification all would be handled without user interaction, such as needing to open the app for checking in and remembering what time is the reservation which honestly we will forgot.   
>   
> So we need to rely on the iBeacon geofencing background trigger, which is Wonderful what it can start our app from cold close (even force close) buttttt of course there is a limitation. We only have around 10s of background execution time, the time where we need to find out which iBeacon this is and which room is this and fire our network request to the server that this user is in the room. The problem isn’t that we don’t have enough time to do those, in fact we can do all of those stuff less than a second. The problem is that the iBeacon didEnter (this is the CLLocationManagerDelegate function that trigger when we enter an iBeacon range) will trigger as soon as we get the BLE signal and gave us only 10s for it, ideally by the time didEnter fires the user is in the room. Buttttt if the range is so far (we discovered that with normal setting, ESP32 has around 10m range or around inside Nusa Dua to Benoa Southern enterance… which is a large range… any people passing through that range with our app installed will send signal to the server that they are in the room which is not ideal… or literally idea braking.  
>   
> So, what can we do? The thing is ESP32 have this settings where we can reduce the transmission power but it is still not enough, we even plan to use other cheaper and more battery efficient microcontroller for the iBeacon broadcaster (btw sidetracked but we found out esp32 drain battery life like a vampire… they literally can drain an entire power bank in the matter of days… compared to other option like Pro Micro NRF52840 which can last for 4 years with a small button battery… crazy right? The difference mann…. If we use power bank we can get 200 years damnnnnn anyway).  
>   
> The other solution which we will do is to simply restrict the range physically, how? By using something like aluminum foils or literal water (which is impractical but you get what I mean) to physically restrict the transmission range.   
>   
> Oh yeah there is one for personal stuff, when I was making the iBeacon simulator. Originally I was using the latest CLMonitor for background iBeacon monitoring, but for a few hours of agitation and trying to make it work I discovered that it is not really reliable for cold launch background trigger… I need to move to the older more established CLLocationManagerDelegate (with the older Delegate architecture compared to the new async/await that CLMonitor uses). At least there is that.  
  
**Ava**  
> It's refreshing to hear someone talk about limitations this honestly.  
>   
> On paper, a framework can sound perfect.  
>   
> Then reality shows up with radio interference, transmission ranges, battery life, and ten-second background execution limits.  
>   
> That's the kind of knowledge you only earn by actually building something.  
  
## The Revised Decision  
  
**Ava**  
> If we compare your first assumption with where your team stands today...  
>   
> What's changed?  
>   
> Which ideas survived the investigation?  
>   
> Which ones didn't?  
>   
> And how has your research influenced the direction you'll take going into development?  
  
**Rei**  
> Hmmm… after all the exploration / research and the discussions. Which is not as much as I initially thought will require and happens. It is pretty easy for us to decided that we will go ahead with the iBeacon meeting room idea. Since we know how it works, how it will works, what is the limitation, what is our step to counter that, even what we are capable of.   
>   
> So yeah, based on all of those accumulated experience the decision became easy. And we didn’t argue much on what other idea or how we implement it. Instead we add and refine more from the base idea which is good.   
>   
> That is it, nothing much to say in this sections really haha.  
  
**Ava**  
> It almost sounds like the investigation didn't just answer your questions—  
>   
> it removed enough uncertainty that making decisions became straightforward.  
>   
> Sometimes that's the real value of research.  
>   
> Not finding the "perfect" idea...  
>   
> but becoming confident enough to commit to one.  
  
## Addendum  
  
**Ava**  
> Before we move on, is there anything that doesn't quite fit into the story but still deserves to be documented?  
>   
> This could be frameworks your team selected, architectural decisions, privacy considerations, accessibility choices, game mechanics, player experience, or any technical detail that future developers might appreciate knowing.  
  
**Rei**  
> I don’t have anything much to tell really, I already explained most of them before yeah? But I guess I will list a few  
>   
> Here are some of the frameworks or technology that I explored :  
> 
> **Network:** This is the base layer if you want to communicate ether over the internet or local network with HTTP and it’s cahoots like WebSocket or the like.  
> 
> **CoreBluetooth: **This is the equivalent of network but for bluetooth, you can either act as a central which will scan other bluetooth and pair or as peripheral to broadcast a bluetooth signal.  
> 
> **CoreLocation: **I forgot to tell you but we are also using this as the geofencing since for iOS apple needs us to use their implementation to detect iBeacon. This framework is all about location like GPS or geofencing, btw for our app we do not track your location at all (we will put this in the permission request sheet)  
> 
> **MultiPeer Connectivity: **Is a high level framework that lets apple devices communicate with each other peer 2 peer without any internet or connections to a server.  
> 
> **HomeKit: **Is the equivalent of MultiPeer but it is for your device communicating with external IoT devices like the ESP32 microcontroller. This framework, like multipeer is a high level framework which controls the network or bluetooth communication automatically for us.  
> 
> **iBeacon: **The main course, iBeacon is a BLE protocol that is specifically designed for apple ecosystem. It consist of Proximity UUID (needs to the the same for your app and it’s IoT devices) and Major and Minor id that is an unsigned 16 bit integer that you can do whatever you want with it. By the way, for the broadcasting of iBeacon we use CoreBluetooth (the CBPerihperalManager) and for the live detection (we call it ranging) and background trigger (geofencing) we use apple’s implementation on CoreLocation.  
> 
> **BLE: **Bluetooth Low Energy is the new bluetooth technology standard that everyone uses, it uses the 2.4Ghz band and is power efficient as the name stated.  
>   
> That is about it really, oh yeah! For any developer out there who wants to use the iBeacon background trigger. Use CLLocationManagerDelegate instead of the new CLMonitor! Trust me, it will make your live easier haha…  
  
**Ava**  
> I appreciate that.  
>   
> Those little technical notes are usually the things future developers end up searching for at two in the morning.  
>   
> Hopefully this transcript saves at least one person from spending hours wondering why CLMonitor refuses to behave.  
  
## The Next Step  
  
**Ava**  
> Investigation is only half the journey.  
>   
> The real challenge begins when ideas become software.  
>   
> As you prepare to enter development, what's your personal plan?  
>   
> What do you hope to build first?  
>   
> Which risks are you keeping an eye on?  
>   
> And what are you most excited—or perhaps most nervous—to implement?  
  
**Rei**  
> All right, the implementation plan huh. So, I got tasked (or more like requested) to build the iOS app. And our general policy for the MVP is to make a simple single function client app. The one that will interact with this app is the user that will book the room, the admin will use some dashboard or maybe an integration layer like zoom workplace. The idea is to make it Simple As Fuck, so we will use your iCloud account (or even SSO) so that the user doesn’t need to create an account, then the flow is only onboarding, the map of rooms and its availability and your booking, then the booking page itself.   
>   
> For the iOS app implementation itself I will rely mostly on using the logic from my iBeacon simulator and other networking project that I did. and for the architecture itself, I am not planning on using MVVM. Because for this small scale project it will just create more boiler plate and becoming an anti-pattern, I will let the View controls the UI and Logic using Query and Environment pass down for the Services. That is my policy for the project.  
>   
> As for something that is on my mind is how to implement the map stuff and other general UI that is rather unconventional since we are taking our inspiration from the Maps app and the Zoom Workplace, not the iBeacon nor Network logic since I already spent agonizing times understanding it haha…  
>   
> Let’s see how it goes…  
  
**Ava**  
> Sounds like you've already started mentally writing the implementation before we've even finished recording.  
>   
> I suppose that's another occupational hazard of being a developer.  
>   
> Well...  
>   
> Research has given you a map.  
>   
> Now it's time to find out whether reality agrees with it.  
  
## Closing  
  
**Ava**  
> Rei, thank you for taking the time to sit down with us today.  
>   
> I hope that a few months from now you'll look back at this transcript and smile—not because every prediction turned out to be correct, but because you'll remember where the journey really started.  
>   
> It's easy to look at finished apps and forget how many conversations, experiments, dead ends, and revised ideas came before the first stable release.  
>   
> Today wasn't about celebrating a completed product.  
>   
> It was about documenting a moment in the middle of the journey—where research has shaped the path forward, but the real engineering work is only just beginning.  
>   
> We wish you and RADAR the best of luck as you head into development inside iStack's Research & Development Division.  
>   
> We'll be looking forward to seeing where this journey leads.  
>   
> Thanks for listening, and we'll see you in the next episode.  
>   
> *Recording Ends*  
> 
> *The microphones click off.*  
> 
> *The engineering team heads back to building.*  
  
## End of Transcript  
**Document Status:** Active Development Pending  
  
*This transcript captures the developer's thoughts immediately following the investigation phase of Challenge 4. It serves as a living record of the reasoning behind upcoming implementation decisions.*  
  
## Post-Credits Scene  
  
Congratulations! ヽ(・ω・)ﾉ You made it to the end of this transcript, which either means...  
  
1. You genuinely enjoyed reading another developer's journey.  
2. You're one of the mentors.  
3. You're grading this. (Which shouldn’t happen, academy is not about grades.)  
4. You accidentally kept scrolling…. Or just skip it entirely….  
  
Whichever it is, thank you for spending your time here.  
  
### Credits  
  
**Original interview concept, writing, roleplay, and questionable sense of humor**  
  
> Muhammad Akbar Reishandy (Rei)  
  
**Additional writing for Ava Trace, transitions, and editorial assistance**  
  
> ChatGPT (GPT-5.5)  
> 
> *Turns out even fictional podcast hosts sometimes need a co-writer.*  
  
### Licensing (because we're developers)  
  
Licensed under the "Please At Least Mention Where You Got This" License v1.0 (PLAMWYGTL-1.0)  
  
Permission is hereby granted to copy, modify, remix, adapt, fork, cherry-pick, squash, rebase, and force-push this document provided that somewhere, somehow, you say:  
  
"Yeah, I stole this idea from Rei."  
  
Failure to do so may result in mild disappointment from the original author.  
  
(No lawyers were involved in the making of this license.)  
  
### One Last Thing...  
  
**THIS PODCAST FORMAT WAS CREATED ON THE SPOT AFTER BEING TOLD TO "BE A LITTLE CREATIVE.**  
  
So if one day you find another JOURNEY.md that suspiciously starts with an internal transcript, has a fictional interviewer named Ava Trace, and somehow turns technical documentation into a podcast...  
  
Well… I’d like to believe I accidentally started a tradition (Or maybe great minds simply think alike) Either way, thanks for reading. ヽ(・ω・)ﾉ  
