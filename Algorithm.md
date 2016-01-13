Transformation of account number into encoded number.
-----------------------------------------------------

## Algorithm 1

Note: Investigation has shown there to be non-numeric (alpha) characters
in some account numbers. In order to be valid across the range of
possible account numbers (even if rare or possibly invalid in other
systems), we use a base-36 system for encoding (10 numeric digits [0-9]
plus 26 upper-case alphabetic characters [A-Z]). Intuitively, A is
assigned the number 11, and so far, and simple base 10 arithmetic is
used in the encoding. This is formalized below using ASCII codes..



### Step 1
Define a 10-digit base-36 key for each origin (this is the
secret key). This will be stored in a lookup database

### Step 2
Receive account number from origin

### Step 3
Convert to base-36 as follows:

```R
function to_base36 (digit) {

if (digit is numeric) code=digit;

else (ascii(digit) in [65-90]) code=ascii(digit)-65+10

}
```

### Step 4
Apply one-time pad, and convert back to the base-36 system:

```R
function base36_to_ascii (result) {

if (result < 10) ascii(48+result)

else (if result in [10,35]) ascii(result-10+65)

else (if result >= 36) base36_to_ascii(result-36)

}
```
Example:

| Information        | Digits: | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|------------------- | --- |:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|:-------:|
| UI account         |     | 1 | 3 | 5 | 7 | 9 | 2 | 4 | L | M | 0 |
| (Decimal)          |     | 1 | 3 | 5 | 7 | 9 | 2 | 4 | 21 | 22 | 0 |
| Key                | +   |**A** | **5** | **1** | **C** | **F** | **4** | **7** | **P** | **B** | **2** |
|(Decimal)           |     | 10 | 5 |  1 |  12 | 15 | 4 |  7 |  25 | 11 | 2 |
| RESULT (raw)       | =   | 11 | 8 |  6 |  19 | 24 | 6 |  11 | 46 | 33 | 2 |
| (ASCII)            |     | 66 | 56 | 54 | 74 | 79 | 54 | 66 | 65 | 88 | 50 |
| RESULT             | =   | **B** | **8** | **6** | **J** | **O** | **6** | **B** | **A** | **X** | **2** |
| (mod 36, base-36)


### Step 5
Prepend origin numeric identifier



## Algorithm 2

It is possible to define a key such that a certain number space is
excluded. For instance, no account numbers have letters in the first two
digits. In order to be able to create pseudo-encoded numbers later in
the process without the risk of collisions, it is possible to define the
first two digits of the key in base-10, yielding a maximum ASCII value
for the first two characters of 75 (“K”). Then, pseudo-encoded numbers
creation in downstream processes can prepend letters with ASCII values
\> 75 without fear of collisions (e.g., “ZZ”).



## Discussion

* The one-time pad is secure and unbreakable, as long as the key is kept separate.
* The algorithm should be stored centrally
* The algorithm is applied as the last stage in wherever account numbers show up
alent.
