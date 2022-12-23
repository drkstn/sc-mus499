//Problem Set 0




//----------
//Problem 0.
//The following code produces an error when evaluated. Correct the error and add a comment indicating the problem. Comments are created by starting a line with two forward slashes, exactly like this line. Remember to use the correct keyboard shortcut to evaluate a multi-line chunk of code.

(
var oranges; // variables must be declared
oranges = 3;
oranges = oranges * 2;
oranges = oranges - 1;
)




//----------
//Problem 1.
//The following code produces an error. Correct the error and add a comment indicating the problem.

(
var oldBalance, deposit, newBalance;
oldBalance = 5; // missing semicolon
deposit = 100;
newBalance = oldBalance + deposit;
)




//----------
//Problem 2.
//The following code produces an error. Correct the error and add a comment indicating the problem.

(
var classroomSize, numClasses, totalStudents;
classroomSize = 30;
numClasses = 4;
totalStudents = classroomSize * numClasses; // 'totalstudents' corrected to 'totalStudents', sclang is case-sensitive
)




//----------
//Problem 3.
//The following code produces an error. Correct the error and add a comment indicating the problem.

(
~func = {
	arg x=5, y=6, z=7; // remove extra comma
	var product;
	product = x * y * z;
};
)




//----------
//Problem 4.
//There are two different syntax styles for passing a method to a receiver. The first, demonstrated in class, takes the form: 'receiver.method' and is called "receiver syntax." For example:

8.class;

//The other syntax, called "function call syntax," takes the form 'method(receiver)' — it begins with the method and continues with the receiver, enclosed in parentheses, like this:

class(8);

//With this in mind, consider the following expression, which returns a boolean (a true/false value) indicating whether the square of 45 is an odd number. It is written entirely in receiver syntax. Rewrite this expression so that it is *entirely* in function call syntax.

45.squared.odd;

odd(squared(45)); // This is very much like a LISP




//----------
//Problem 5.
//Write a comment that explains why the following code expression produces an error message.

45.odd.squared;
// 45.odd returns a Boolean.
// Booleans don't have a 'squared' method
// Cannot use unary/binary operators on Booleans?



//----------
//Problem 6.
//The 'postln' method is useful for printing the values of code statements, allowing us to see additional information about code as it runs. This is particularly helpful for debugging broken code. For example, the following function squares an input value, posts the value, and then continues by subtracting 1, and returns the result:

(
~func = {
	arg num;
	num = num.squared;
	num.postln;
	num = num - 1;
};
)

~func.(6);

//Write a function that accepts three input arguments and prints the class that each item belongs to. Add at least one additional line of code that evaluates the function, to demonstrate that it works.

(
~func2a = {
	arg arg1, arg2, arg3;
	arg1.class.postln;
	arg2.class.postln;
	arg3.class.postln;
	[arg1, arg2, arg3]
};
)

~func2a.('cat', "dog", 99)

// OR
// Pass an array to function to print classes of any number of items

(
~func2b = {
	arg arr;
	arr.do({arg item; item.class.postln});
};
)

~func2b.(['cat', "dog", 99, 472.75])




//----------
//Problem 7.
//Create a named function that takes an Array as an input argument, and returns that same Array in which the first and last items have switched positions. If the input array has only one item, the function should return that same array, unaltered. After creating this function, include one or more additional lines of code that evaluate the function, to demonstrate that it works correctly (there are multiple ways to solve this problem).

(
~func3 = {
	arg arr;
	arr.swap(0, arr.size - 1);
};
)

~func3.([0, 1, 2, 3, 4, 5]);




//----------
//Problem 8.
//Write a line of code that boots the audio server. Then, write a named UGen function that generates a sine wave. The function should include an argument for the amplitude of the sine wave (i.e. the 'mul' argument of SinOsc). Include a few additional lines of code that play the UGen function with different amplitude values, to demonstrate that it works (please only use 'mul' values that are between 0 and 1). For each line of code that produces sound, include a line of code that stops that sound (I shouldn't need to press command-period).

s.boot;

(
~mySine = {
	arg freq, amp;
	SinOsc.ar(freq!2, 0, amp, 0)
};
)

x = ~mySine.play(args: [\freq, 220, \amp, 0.2]);
x.free;

y = ~mySine.play(args: [\freq, 440, \amp, 0.1]);
y.free;



