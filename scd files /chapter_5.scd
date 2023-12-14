//Programming in SuperCollider

//5.1: Introduction


//5.2: Fundamental Elements of Programs
//5.2.1: Objects and Classes
//OOP: all entities inside a program are some kind of object

//5.2.1.1: Objects
//Objects: basic entities that are manipulated within programs
//Collection: object with a variable number of internal slots for storing data


//5.2.1.2: Classes
//Class: describes the attributes and behavior that are common to a group of objects
//Instance: all objects belonging to a class
//Inheritance: mechanism central in object-oriented programming


//5.2.2: Literals
//Literals: objects whose value is represented directly in the code
// - integers
// - floating point numbers
// - strings "string"
// - symbols 'symbol', \symbol
// - literal arrays: immutable arrays of literals declared by prepending the # (#[])
// - classes: start with a capital letter
// - characters:
// - variables and constants

//5.2.3: Messages and Methods
//To interact with an object, one sends it a message

15.squared;

//Receiver: object to which a message is sent
//Method: has same name as message
//Return value:
//Instance Methods: operate on instance
//Class Methods: operate on a class, most common being .new

squared(15) //C or Java-style

//5.2.3.1: Chaining Messages
Server.local.boot;

Server.local.quit;

//5.2.3.2: Performing messages
//In some cases, the message to be sent to an object may change, depending on other conditions
//When the message is not known in advance, the messages perform and performList are used

Server.local.perform(\boot);
Server.local.perform([\boot, \quit].choose);

//performList: permits one to pass additional arguments to the message in Array form
Rect.performList(\new, [0, 10, 200, 20]);
Rect.new(0, 10, 200, 20);

//5.2.4: Arguments
//Arguments: enclosed in parentheses after the message

5.pow(8);

//separated by commas if several are involved
Array.series(5, 10, 10); //construct an array of 5 elements starting at 10 and incrementing by 10

series(Array, 5, 10, 10); //'function-call' format

//"If the arguments are provided as 1 collection containing several objects, they can be separated into individual values by prepending the * sign to the collection:

Array.rand(*[5, -10, 10]);
Array.rand(5, -10, 10);

Array.rand(*Array.rand(3, 3, 10));

//when the only argument to a message is a function, the parantheses can be omitted
10.do{ 10.rand.postln}

//5.2.4.1: Argument forms for implied messages at and put
[1, 5, 12][1];
[1, 5, 12].at(1);
()[\a] = pi;
().put(\a, pi);


//5.2.4.2: Argument keywords
//When calling a function, argument values must be provided in the order in which the arguments were defined


//Figure 5.3: Keyword arguments
//boot the default server first
s.boot;
(
{
	Resonz.ar(GrayNoise.ar,
		XLine.kr(100, 1000, 10, doneAction:2),
		XLine.kr(0.5, 0.01, [4,7], doneAction:0)
	)
}.play;
)
//further examples:
{ WhiteNoise.ar(EnvGen.kr(Env.perc, timeScale: 3, doneAction: 2))}.play;
{ WhiteNoise.ar(EnvGen.kr(Env.perc, timeScale: 0.3, doneAction: 2))}.play;

//5.2.5: Binary Operators
//Binary Operators: operate on 2 objects
//"any message that requires 1 arg can be written as binary operator by adding : to the name of the message

5.pow(8);
5 pow: 8;

//dot notation is most common for vanilla SC


//Figure 5.4: Grouping and Precedence

((1+2).asString).interpret; // = 3
"1" ++ "2".interpret; //12: 2 is translated to string by ++
("1" ++ "2").interpret; // 12
(1.asString ++ 2.asString).interpret; //12
"1+2".interpret; //3
(1.asString ++ "+2").interpret; //3
(1 + 2).interpret; //error: interpret bot understood by


//5.2.6: Precedence Rules and Grouping
//Binary Operators are evaluated in strict left-to-right order
//Message passing, as in receiver.message(arguments) or collection[index] has precedence over binary operators




//5.2.7: Statements
//Statement: the smallest stand-alone element of code

//Figure 5.5: Statements
(
a = 5;
5 do: { a = a + 10; a.postln };
Post << "The value of variable 'a' is now " << a << "\n";
)


//5.3: Variables
//Variable: used to store an object that will be used in other parts of a program
// - container with labels
// - declared with the prefix var
// - may be declared only at the beginning of a function

var window;

(
var window;
window.postln;
)

//variables declared in the beginning of a function disappear from memory as soon as the the function that declared them finishes

//to store an object in a variable, use the assignment sign =


//5.3.1: Variable Initialization


//Figure 5.8: Variables can store objects that need to be used many times
(
//A window with a button that posts: "hello there!"
var window, button;
//create a GUI window and store it in variable window
window = Window.new("OLA!", Rect(200, 200, 120, 120));
//create a button in the new window and store it in variable button
button = Button.new(window, Rect(10, 10, 100, 100));
button.states = [["ALLO"]];
button.action = { "hello there!".postln };
window.front;
)

(
var bounds = Rect(10, 20, 30, 50), x = 100, y = 200;
bounds.width.postln; // post the width of a rectangle
bounds.moveTo(x, y); // move the rectangle to a new position
)


//5.3.3: Instance Variables
//Instance Variable: variable that is contained in a single object
// - accessible only inside instance methods of that object unless special code is written to make it accessible to other objects


(
var point = Point(0, pi);
point.x.postln; point.y.postln; point.y == pi;
)
//Figure 5.9: Variables can point to different objects during a process
(
//execute this first to boot the server and load the synth definition
Server.default.waitForBoot({
	SynthDef(\ping, {
		|freq=440|
		Out.ar(0,
			SinOsc.ar([freq, freq*(4/3)], 0,
				EnvGen.kr(Env.perc(0.05, 0.3, 0.1, -4), doneAction:2)
			)
		)
	}).add;
})
)

(
//execute this next to create the sounds
var countdown = 100;
var note = 50;
var increment_func, decrement_func;
var action;

increment_func = {
	note = note + [2, 5, 7, 12].choose;
	if (note > 100) {action = decrement_func};
};

decrement_func = {
	note = note - [1, 2, 5, 7, 12].choose;
	if (note < 50) { action = decrement_func };
};

action = increment_func;
{
	countdown do: {
		Synth(\ping, [\freq, note.midicps]);
		action.value;
		0.1.wait;
	}
}.fork;
)

//5.3.4: Class Variables

//Class Variable: defined once for the class to which it belongs
// - shared with all sub-classes


//5.3.5: Enivronment Variables
//Environment Variables:
// - preceded by ~



//Figure 5.11: currentEnvironment


//run each line separately
currentEnvironment; //empty if no environment variables have been set
~alpha = pi; // set env. variable ~alpha to pi
currentEnvironment; //see current Environment again: ~alpha is set
~freq = 800; //set another environment variable
Server.local.boot;
{ LFNoise0.ar(~freq, 0.1) }.play; //use an environment variable
~alpha = nil; //setting an environment variable to nil is equivalent to removing it
currentEnvironment; //alpha is no longer set


//5.3.6.1: Interpreter Variables

n = { |freq=400| LFDNoise1.ar(freq, 0.1) }.play; //store a synth in n
n.set(\freq, 1000);  //set the freq parameter of the synth to 1000
n.free; //free the synth (stop its sound)

//5.3.6.2: Pseudo variables
//Not declared anywhere in the SC library
//Provided by compiler

//this: represents object running the current method

//thisProcess: process running the current code
//always an instance of Main

//thisMethod: method in within which the current statement is running

//thisFunction: innermost function withing which the current statement is running
//indispensable for recursion in functions

//thisFunctionDef: definition of innermost function within which the current statement is running
//contains information about the names and default values of arguments and variables

//thisThread: thread running current code
//thread: sequence of execution that can run in parallel with other threads and can control the time of the execution of individual statements in the program

//super: redirects the message sent to it to look for a method belonging to the superclass of the object in which the method of the current code is running
//used to extend a method in a subclass



//5.3.6.3: Class variables of Object

//currentEnvironment: Environment currently being used
//topEnvironment: original currentEnvironment
//uniqueMethods: holds a dictionary that stores unique methods of objects


//Figure 5.12: topEnvironment versus currentEnvironment
(
~a = "TOP"; //store "TOP" in ~a, top environment
(a: "INNER") use: { //run function in environment with ~a = "INNER"
	currentEnvironment.postln;
	topEnvironment.postln;
	~a.postln;
};
~a;
)

(
//create 2 windows and store them in variables p, q
#p, q = [100, 400].collect{|i|
	Window(i.asString, Rect(i, i, 200, 200)).front
};
)

//add a unique method to p only
p.addUniqueMethod(\greet, {|w| w.name = "Hello!"});
p.greet; //p understands 'greet'
q.greet; //q does not understand 'greet'

//dependantsDictionary: stores dependants of Objects
//a dependant of an Object o is any object that needs to be notified when o changes in some way

//5.3.7: Variables versus Reference

var aref, cvar;
aref = Ref.new; //first create the reference and store it in aref
cvar = aref; //then store the contents of aref in cvar

//Figure 5.13: Variables store only values, not other variables

(
var alpha, beta, gamma;
gamma = alpha; //storing variable alpha in gamma only stores nil
alpha = 10; //store 10 in alpha
gamma.postln; //but the value of gamma remains unchanged
alpha = beta; //so one cannot use gamma as 'joker'
beta = 20; //to switch between variables alpha and beta
gamma.postln; //gamma is still nil
)
var aref;
aref.value = 10;
cvar.value.postln;


//5.4: Functions

{1+1}.value;

//5.4.1: Return Value versus Side Effect

//5.4.2: Functions as Program Mode

//Figure 5.15: Multiple use of a function stored in a variable
Server.default.boot;

(
//Define a function and call it in different contexts
var synth; //Synth creating the sound that is changed
var freq = 220; //frequency of the sound
var change_freq; //function that changes the frequency of the sound
var window; //window holding buttons for changing the sound
var button1, button2, button3; //buttons changing the sound

//Create a synth that plays the sound to be controlled;
synth = {|freq = 220| LFTri.ar([freq, freq*2.01], 0, 0.1)}.play;

//Create frequency changing function and store it in variable change_freq
change_freq = {
	freq = freq * [0.9, 0.9.reciprocal].choose;
	synth.set(\freq, freq);
};

window = Window("Buttons Archaic", Rect(400, 400, 340, 120));

button1 = Button(window, Rect(10, 10, 100, 100));
button1.states = [["I"]];
button1.action = change_freq;

button2 = Button(window, Rect(120, 10, 100, 100));
button2.states = [["II"]];
button2.action = {
	{3 do: { change_freq.value; 0.4.wait } }.fork;
};

button3 = Button(window, Rect(230, 10, 100, 100));
button3.states = [["VIII"]];
button3.action = {
	{8 do: { change_freq.value; 0.1.wait }}.fork;
};

[button1, button2, button3] do: _.font_(Font("Times", 32));
window.onClose = {synth.free};
window.front;
)


//5.4.3.1: Who does the compiling?


{3+5}.def.dumpByteCodes;

(
var sum2; //define variable to store the function
sum2 = {|a, b| a + b};
sum2.value(2,3);
)

//5.4.4.1: Defining arguments

//Figure 5.18: Simple function with arguments
(
var sq_mean;
sq_mean = {|a,b| (a+b/2).squared};
sq_mean.value(3,1);
)

//Figure 5.19: using ...for undefined number of arguments
(
var sq_mean_all;
sq_mean_all = {|...numbers| (numbers.sum/numbers.size).squared};
sq_mean_all.(1,3,5,-7);
)

//5.4.4.2: Default argument values
//see first-class objects

//5.4.5: Customizing the Behavior of Objects with Functions


//Figure 5.20: Using and overriding default values of arguments
(
var w_func;
w_func = {arg message="warning", bounds=Rect(200, 500, 500, 100);
	var window;
	window = Window("message window", bounds).front;
	TextView(window, window.view.bounds.insetBy(10, 10))
	.string = message;
};
w_func.(String.new.addAll(Array.new.addAll("Major News!").pyramid(7)));
)

//Figure 5.21: Performing messages chosen by index
(
var window, button;
window = Window("Server Button", Rect(400, 400, 200, 200));
button = Button(window, Rect(5, 5, 190, 190));
button.states = [["boot!"], ["quit!"]];
button.action = {|me| Server.default perform: [\quit, \boot][me.value] };
window.front;
)

//Figure 5.4.6: Functions as Arguments in Messages for Asynchronous Communication

(
var window, button;
window = Window("Server Button", Rect(400, 400, 200, 200));
button = Button(window, Rect(5, 5, 190, 190));
button.states = [["boot!"], ["quit!"]];
button.action = {|me|
	[{ "QUITTING THE DEFAULT SERVER".postln;
		Server.default.quit;
	},{ "BOOTING THE DEFAULT".postln;
		Server.default.boot;
	}][me.value].value;
};
window.front;
)


//Figure 5.4.6.1: Asynchronous communication with a Server

//Figure 5.23: Asynchronous communication with the server
(
var buffer;
buffer = Buffer.read(path: "sounds/allwlk01.wav",
	action: {|buffer|
		format("loaded % at: %", buffer, Main.elapsedTime).postln;
});
format("Reached this after 'Buffer.read' at: %", Main.elapsedTime).postln;
buffer;
)

//5.4.7: Iterating Functions

//Iteration: technique of repeating the same function a number of times

//5.4.7.1: Iterating a specified number of times

10 do: {|i| [i, i.squared, i.isPrime].postln};
{10.rand * 3}!5;
30.for(35, {|i| i.postln});
2.0.forBy(10, 1.5, {|i| i.postln});


//5.4.7.2: Iterating while a condition is true

//Figure 5.24: Illustrates 'loop' and the use of Event to play notes


(
var window, routine;
window = Window("close me to stop").front;
window.onClose = { routine.stop };
routine = {
	loop  {
		(degree: -10 + 30.xrand, dur: 0.05, amp: 0.1.rand).play;
		0.05.rand.wait;
	}
}.fork;
)

(
var sum = 0;
while {sum = sum + exprand(0.1, 3); sum < 10} {sum.postln}
)

//5.4.8: Partial Application: Shortcut Syntax for Small Functions










































