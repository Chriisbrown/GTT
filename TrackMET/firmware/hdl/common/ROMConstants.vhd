library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;


package ROMConstants is
  type intArray is array(natural range <>) of integer;

  constant ATanLUT   : intArray(0 TO 7) := (
    2048,
    1209,
    639,
    324,
    163,
    81,
    41,
    20
  );

  constant RenormLUT   : intArray(0 TO 7) := (
    23170,
    20724,
    20106,
    19950,
    19911,
    19902,
    19899,
    19899
  );

  constant TrigArray : intArray(0 TO 256) := (
    255,
254,
254,
254,
254,
254,
254,
254,
254,
254,
254,
254,
254,
254,
254,
253,
253,
253,
253,
253,
253,
252,
252,
252,
252,
251,
251,
251,
251,
250,
250,
250,
250,
249,
249,
249,
248,
248,
248,
247,
247,
246,
246,
246,
245,
245,
244,
244,
243,
243,
243,
242,
242,
241,
241,
240,
239,
239,
238,
238,
237,
237,
236,
236,
235,
234,
234,
233,
232,
232,
231,
230,
230,
229,
228,
228,
227,
226,
226,
225,
224,
223,
223,
222,
221,
220,
220,
219,
218,
217,
216,
215,
215,
214,
213,
212,
211,
210,
209,
209,
208,
207,
206,
205,
204,
203,
202,
201,
200,
199,
198,
197,
196,
195,
194,
193,
192,
191,
190,
189,
188,
187,
186,
185,
184,
183,
181,
180,
179,
178,
177,
176,
175,
174,
172,
171,
170,
169,
168,
167,
165,
164,
163,
162,
161,
159,
158,
157,
156,
154,
153,
152,
151,
149,
148,
147,
146,
144,
143,
142,
140,
139,
138,
136,
135,
134,
132,
131,
130,
128,
127,
126,
124,
123,
122,
120,
119,
117,
116,
115,
113,
112,
110,
109,
108,
106,
105,
103,
102,
100,
99,
97,
96,
95,
93,
92,
90,
89,
87,
86,
84,
83,
81,
80,
78,
77,
75,
74,
72,
71,
69,
68,
66,
65,
63,
62,
60,
59,
57,
56,
54,
53,
51,
49,
48,
46,
45,
43,
42,
40,
39,
37,
36,
34,
32,
31,
29,
28,
26,
25,
23,
21,
20,
18,
17,
15,
14,
12,
10,
9,
7,
6,
4,
3,
1,
1,
0);


end ROMConstants;
  