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







