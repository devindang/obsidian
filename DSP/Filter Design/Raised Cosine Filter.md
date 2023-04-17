#reserved 

A ==raised cosine filter== is applied for ==pulse shaping== due to its ability of minimise Intersymbol Interference (ISI). 

## Nyquist Criterion

Raised cosine filter is an implementation of Nyquist Filter, which satisfy ==Nyquist Criterion== for ISI-free transimition. 

If we denote the channel impulse response as $h(t)$，the ISI-free criterion can be expressed as:
$$h(nT_s)=\left\{\begin{aligned}1;\quad&n=0\\0;\quad&n\neq0\end{aligned}\right.$$
