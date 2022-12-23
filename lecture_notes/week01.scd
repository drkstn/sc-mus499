// WEEK 01

7 + 32;

(
var num;
num = 6;
num = num * 4;
num = num - 1;
)

(
~num = 6;
~num = ~num * 4;
~num = ~num - 1;
)
~num;

(
n = 6;
n = n * 4;
n = n - 1;
)

n;

(
~func = {
	var num;
	num = 6;
	num = num * 5;
	num = num - 1;
};
)

~num = ~func.value;

(
~func = {
	arg num;
	num = num * 4 - 1;
};
)

~num = ~func.value(7);
~num = ~func.(10).class;

"string".class;
'sym'.class;

~myArr = [1, "hi", 56.987, \sym];
~myArr;

~nums = [150, 190, 240, 345];
~nums.at(0);
~nums[0];
~nums.at(3).class;

~myArr.reverse;
~myArr.scramble;
~nums.normalize();

s.boot;

(
~mySound = {
	arg freq;
	SinOsc.ar(freq!2, 0, 0.1, 0);
};
)

x = ~mySound.play(args: [\freq, 500]);
x.free;