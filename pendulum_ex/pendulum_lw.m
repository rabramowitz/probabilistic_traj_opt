function [l, E, K] = pendulum_lw(x, u, h, Q_l, R_l)
%PENDULUM_LW Robust Cost Function Described in Dirtrel Paper (Algorithm 1)

global R Q Q_N E1 D N g m L;

if N-1 ~= size(u)
    print("Size of X != Size of U+1")
    return
end

l = 0;
A = cell(N,1);
B = cell(N,1);
G = cell(N-1,1);
K = cell(N-1,1);
H = cell(N,1);
E = cell(N,1);
E{1} = E1;
for i = 1:N
    theta_i = x(2*i-1);
    theta_dot_i = x(2*i);
    A{i} = [ 1 h; (-g/L*cos(theta_i)*h) 1 ];
    B{i} = [ 0; h/(m*L*L) ];
    if i ~= N
        G{i} = [ 0 0; -h*u(i)/(L*L*m*m) 0];
    end
end
P = cell(N,1);
P{N} = Q_N;
for i = N:-1:2
    P{i-1} = Q + A{i}'*P{i}*A{i}-A{i}'*P{i}*B{i}*...
        inv(R+B{i}'*P{i}*B{i})*(B{i}'*P{i}*A{i});
end
for i = 1:N-1
    K{i} = inv(R+B{i}'*P{i+1}*B{i})*(B{i}'*P{i+1}*A{i});
end
H{1} = [0 0; 0 0];
for i = 1:N-1
    l = l + trace((Q_l+K{i}'*R_l*K{i})*E{i});
    E{i+1} = (A{i}-B{i}*K{i})*E{i}*(A{i}-B{i}*K{i})' + ...
        (A{i}-B{i}*K{i})*H{i}*G{i}' + ...
        G{i}*H{i}'*(A{i}-B{i}*K{i})' + ...
        G{i}*D*G{i}';
    H{i+1} = (A{i}-B{i}*K{i})*H{i}+G{i}*D;
end
l = l + trace(Q_N*E{N});
end

