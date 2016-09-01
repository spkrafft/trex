function R = imnoise2(type,varargin)
%IMNOISE2 Generates an array of random numbers with specified PDF.
%   R = IMNOISE2(TYPE,M,N,A,B) generates an array, R, of size M-by-N, whose
%   elements are rsondom numbers of the specified TYPE with parameters A
%   and B. If only TYPE is included in the input argument list, a single
%   random number of the specified TYPE and default parameters shown below
%   is generated. If only TYPE, M, and N are provided, the default
%   parameters shown below are used. If M = N = 1, IMNOISE2 generates a
%   single random number of the specified TYPE and parameters A and B.
%
%   Valid values for TYPE and parameters A and B are:
%
%   'salt & pepper' Salt and pepper numbers of amplitude 0 with probability
%                   Pa = A, and amplitude 1 with probability Pb = B. THe
%                   default values are Pa = Pb = A = B = 0.05. Note that he
%                   noise has values 0 (with probability Pa = A) and 2
%                   (with probability Pb = B), so scaling is necessary if
%                   values other than 0 and 1 are required. The noise
%                   matrix R is assigned three values. If R(x,y) = 0, the
%                   noise at (x,y) is pepper (black). If R(x,y) = 1, the
%                   noise at (x,y) is salt (white). If R(x,y) = 0.5, there
%                   is no noise assigned to coordinates (x,y).
%   'uniform'       Uniform random numbers in the interval (A,B). The
%                   default values are (0,1).
%   'gaussian'      Gaussian random numbers with mean A and standard
%                   deviation B. The default values are A = 0, B = 1.
%   'lognormal'     Lognormal numbers with offset A and shape parameter B.
%                   The defaults are A = 1, B = 0.25.
%   'rayleigh'      Rayleigh noise with parameters A and B. The default
%                   values are A = 0 and B = 1.
%   'exponential'   Exponential random numbers with parameter A. The
%                   default is A = 1.
%   'erlang'        Erlang (gamma) random numbers with parameters A and B.
%                   B must be a positive integer. The defaults are A = 2
%                   and B = 5. Erlang random numbers are approximated as
%                   the sum of B exponential random numbers.

% Set defaults
[M,N,a,b] = setDefaults(type,varargin{:});

% Begin processing. Use lower(type) to protect against input being
% capitalized.
switch lower(type)
    case 'uniform'
        R = a + (b-a)*rand(M,N);
    case 'gaussian'
        R = a + b*randn(M,N);
    case 'salt & pepper'
        R = saltpepper(M,N,a,b);
    case 'lognormal'
        R = exp(b*randn(M,N)+a);
    case 'rayleigh'
        R = a + (-b*log(1-rand(M,N))).^0.5;
    case 'exponential'
        R = exponential(M,N,a);
    case 'erlang'
        R = erlang(M,N,a,b);
    otherwise
        error('Unknown distribution type')
end

%%
clearvars -except R

%--------------------------------------------------------------------------
function R = saltpepper(M,N,a,b)

if (a+b) > 1
    error('The sum Pa+Pb must not exceed 1.')
end
R(1:M,1:N) = 0.5;

X = rand(M,N);
R(X<=a) = 0;
u = a+b;
R(X>a & X<=u) = 1;

%%
clearvars -except R

%--------------------------------------------------------------------------
function R = exponential(M,N,a)

if a <= 0
    error('Parameter a must be positive for exponential type.')
end

k = -1/a;
R = k*log(1-rand(M,N));

%%
clearvars -except R

%--------------------------------------------------------------------------
function R = erlang(M,N,a,b)

if (b ~= round(b) || b <= 0)
    error('Param b must be a positive integer for Erlang.')
end

k = -1/a;
R = zeros(M,N);
for j = 1:b
    R = R + k*log(1-rand(M,N));
end

%%
clearvars -except R

%--------------------------------------------------------------------------
function varargout = setDefaults(type,varargin)
varargout = varargin;

P = numel(varargin);
if P < 4
    varargout{4} = 1;
end
if P < 3
    varargout{3} = 0;
end
if P < 2
    varargout{2} = 1;
end
if P < 1
    varargout{1} = 1;
end
if (P<=2)
    switch type
        case 'salt & pepper'
            varargout{3} = 0.05;
            varargout{4} = 0.05;
        case 'lognormal'
            varargout{3} = 1;
            varargout{4} = 0.25;     
        case 'exponential'
            varargout{3} = 1;
        case 'erlang'
            varargout{3} = 2;
            varargout{4} = 5;
    end
end

%%
clearvars -except R
