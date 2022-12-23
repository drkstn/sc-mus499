// WEEK 02

// Conditional Logic
// See 'Control Structures' in Help Browser

2 == 2;
2 != 2;
2 > 3;
2 < 3;
2 <= 3;
2 >= 3;

if ([0,1].choose == 0) {"0 was chosen".postln} {"1 was chosen".postln}

(
if (
	[0,1].choose == 0,
	{"0 was chosen".postln},
	{"1 was chosen".postln}
);
)

~func = {arg input; if (input > 5) {"sine".postln} {"noise".postln}}
~func.(6)
~func.value(4)

(
~func = {
	arg input;
	var result;
	result = case
		{input < 0} 	{"sine"}
		{input > 10}	{"noise"}
		{true} 			{"sawtooth"};
	result.postln;
}
)
~func.(-1)


// Receiver Notation vs. Function Call Notation

3.squared; // Receiver
squared(3); // Function Call


// Randomness
// See 'Randomness' in Help Browser

rrand(10, 11) // inclusive
rrand(-20, 100) // inclusive




// Useful Audio Server Utilities