## radix-2 DIT FFT algorithm

By the definition of DFT, 
$$X_k=\sum_{n=0}^{N-1}x_n e^{-j2\pi kn/N}$$
and introduce the notation $W_N$ 
$$W_N=e^{-j2\pi /N}$$
Hence, 
$$X_k=\sum_{n=0}^{N-1}x_n W_N^{kn}$$
Let $x_{2m}$ and $x_{2m+1}$ consist of even numbered samples and odd numbered samples, separately, for $m=0,1,2\dots \frac{N}{2}-1$, $X_k$ becomes 
$$X_k=\sum_{m=0}^{N/2-1}x_{2m}W_N^{k(2m)}+\sum_{m=0}^{N/2-1}x_{2m+1}W_N^{k(2m+1)}$$
But, $W_N^2=W_{N/2}$, with this substitution, the equition can be expressed as 
$$X_k=\sum_{m=0}^{N/2-1}x_{2m}W_{N/2}^{km}+W_N^k\sum_{m=0}^{N/2-1}x_{2m+1}W_{N/2}^{km}$$
where, let $F_1(k)=\sum_{m=0}^{N/2-1}x_{2m}W_{N/2}^{km}$ and $F_2(k)=\sum_{m=0}^{N/2-1}x_{2m+1}W_{N/2}^{km}$ denotes the N/2 points DFT of $x_{2m}$ and $x_{2m+1}$ , seperately. The scope of $k$ becomes $0,1,2,\dots N/2-1$
Hence, 
$$X_k=F_1(k)+W_N^kF_2(k),\quad k=0,1,2,\dots N/2-1$$
In addition, the factor $W_N^{k+N/2}=-W_N^k$, thus 
$$X(k+\frac{N}{2})=F_1(k)-W_N^kF_2(k),\quad k=0,1,2,\dots N/2-1$$
The butterfly calculation pattern is illustrated bellow:

The twiddle factor pattern is illustrated bellow:
![[tw_factor.svg]]

## radix-2 DIT IFFT algorithm


By the definition of IDFT (discard $\frac{1}{N}$), 
$$x_n=\sum_{k=0}^{N-1}X_k e^{j2\pi kn/N}$$
and introduce the notation $W_N$ 
$$W_N=e^{-j2\pi /N}$$
Hence, 
$$x_n=\sum_{k=0}^{N-1}X_k W_N^{-kn}$$

Let $X_{2l}$ and $X_{2l+1}$ consist of even numbered samples and odd numbered samples, separately, for $l=0,1,2\dots \frac{N}{2}-1$, $x_n$ becomes 
$$x_n=\sum_{l=0}^{N/2-1}X_{2l}W_N^{-k(2l)}+\sum_{l=0}^{N/2-1}X_{2l+1}W_N^{-k(2l+1)}$$
But, $W_N^2=W_{N/2}$, with this substitution, the equition can be expressed as 
$$x_n=\sum_{l=0}^{N/2-1}X_{2l}W_{N/2}^{-kl}+W_N^{-k}\sum_{l=0}^{N/2-1}X_{2l+1}W_{N/2}^{-kl}$$
Hence, 
$$x_n=f_1(n)+W_N^{-k}f_2(n),\quad n=0,1,2,\dots N/2-1$$
