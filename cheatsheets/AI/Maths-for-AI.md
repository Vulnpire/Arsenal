# Mathematics Refresher for AI

You don't need to master everything here.

## Basic Arithmetic Operations

### Multiplication (`*`)
The multiplication operator denotes the product of two numbers or expressions.
```python
3 * 4 = 12
```

### Division (`/`)
The division operator denotes dividing one number or expression by another.
```python
10 / 2 = 5
```

### Addition (`+`)
The addition operator represents the sum of two or more numbers or expressions.
```python
5 + 3 = 8
```

### Subtraction (`-`)
The subtraction operator represents the difference between two numbers or expressions.
```python
9 - 4 = 5
```

## Algebraic Notations

### Subscript Notation (`x_t`)
Represents a variable indexed by `t`, often indicating a time step in a sequence.
```python
x_t = q(x_t | x_{t-2})
```

### Superscript Notation (`x^n`)
Denotes exponents or powers.
```python
x^2 = x * x
```

### Norm (`||...||`)
Measures the size or length of a vector.
```python
||v|| = sqrt(v_1^2 + v_2^2 + ... + v_n^2)
```

Other norms:
```python
||v||_1 = |v_1| + |v_2| + ... + |v_n|
||v||_∞ = max(|v_1|, |v_2|, ..., |v_n|)
```

### Summation Symbol (`Σ`)
Indicates the sum of a sequence of terms.
```python
Σ_{i=1}^{n} a_i
```

## Logarithms and Exponentials

### Logarithm Base 2 (`log2(x)`)
Often used in information theory to measure entropy.
```python
log2(8) = 3
```

### Natural Logarithm (`ln(x)`)
Logarithm with base `e`.
```python
ln(e^2) = 2
```

### Exponential Function (`e^x`)
Represents Euler's number `e` raised to the power of `x`.
```python
e^2 ≈ 7.389
```

### Exponential Function (Base 2) (`2^x`)
Used in binary systems and information metrics.
```python
2^3 = 8
```

## Matrix and Vector Operations

### Matrix-Vector Multiplication (`A * v`)
```python
A * v = [[1, 2], [3, 4]] * [5, 6] = [17, 39]
```

### Matrix-Matrix Multiplication (`A * B`)
```python
A * B = [[1, 2], [3, 4]] * [[5, 6], [7, 8]] = [[19, 22], [43, 50]]
```

### Transpose (`A^T`)
```python
A = [[1, 2], [3, 4]]
A^T = [[1, 3], [2, 4]]
```

### Inverse (`A^{-1}`)
```python
A = [[1, 2], [3, 4]]
A^{-1} = [[-2, 1], [1.5, -0.5]]
```

### Determinant (`det(A)`)
```python
det(A) = 1 * 4 - 2 * 3 = -2
```

### Trace (`tr(A)`)
```python
tr(A) = 1 + 4 = 5
```

## Set Theory

### Cardinality (`|S|`)
```python
S = {1, 2, 3, 4, 5}
|S| = 5
```

### Union (`∪`)
```python
A = {1, 2, 3}, B = {3, 4, 5}
A ∪ B = {1, 2, 3, 4, 5}
```

### Intersection (`∩`)
```python
A ∩ B = {3}
```

### Complement (`A^c`)
```python
U = {1, 2, 3, 4, 5}, A = {1, 2, 3}
A^c = {4, 5}
```

## Comparison Operators

- **Greater Than or Equal To (`>=`)**: `a >= b`
- **Less Than or Equal To (`<=`)**: `a <= b`
- **Equality (`==`)**: `a == b`
- **Inequality (`!=`)**: `a != b`

## Eigenvalues and Scalars

### Lambda (Eigenvalue) (`λ`)
```python
A * v = λ * v, where λ = 3
```

### Eigenvector
```python
A * v = λ * v
```

## Functions and Operators

### Maximum Function (`max(...)`)
```python
max(4, 7, 2) = 7
```

### Minimum Function (`min(...)`)
```python
min(4, 7, 2) = 2
```

### Reciprocal (`1 / ...`)
```python
1 / x where x = 5 results in 0.2
```

### Ellipsis (`...`)
Represents continuation of a pattern or sequence.
```python
a_1 + a_2 + ... + a_n
```

## Probability and Statistics

### Function Notation (`f(x)`)
```python
f(x) = x^2 + 2x + 1
```

### Conditional Probability (`P(x | y)`)
Denotes probability of `x` given `y`.
```python
P(Output | Input)
```

### Expectation (`E[...]`)
```python
E[X] = sum x_i P(x_i)
```

### Variance (`Var(X)`)
Measures spread of data.
```python
Var(X) = E[(X - E[X])^2]
```

### Standard Deviation (`σ(X)`)
Square root of variance.
```python
σ(X) = sqrt(Var(X))
```

### Covariance (`Cov(X, Y)`)
Measures relationship between two variables.
```python
Cov(X, Y) = E[(X - E[X])(Y - E[Y])]
```

### Correlation (`ρ(X, Y)`)
Normalized covariance.
```python
ρ(X, Y) = Cov(X, Y) / (σ(X) * σ(Y))
```

