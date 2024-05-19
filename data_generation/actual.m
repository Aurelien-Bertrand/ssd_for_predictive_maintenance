clear

vsp_11 = 0.004; % First Harmonic
vrp_11 = 0.004;

vsp_12 = 0.002; % Second Harmonic
vrp_12 = 0.002;

vsp_13 = 0.0015; % Third Harmonic
vrp_13 = 0.0015;

v_21 = 0.1; % Fundamental Meshing Harmonic
v_31 = 0.5; % Fundamental Meshing Harmonic

alpha_1 = 0.9; % Damping with respect to the sun
alpha_2 = 0.4; % Damping with respect to the first parallel gear mesh
alpha_3 = 0.3; % Damping with respect to the second parallel gear mesh

% planetary gear
z_r = 99; % No of teeths on ring
z_s = 21; % No of teeths on sun
z_p = 38; % No of teeths on planets
phi_1 = 0; % phase angle with first planetary gear
phi_2 = 120; % phase angle with second planetary gear
phi_3 = 240; % phase angle with third planetary gear

% First parallel gear mesh
z_g1 = 95; % No of teeths on g1
z_g2 = 21; % No of teeths on g2

% Second parallel gear mesh
z_g3 = 123; % No of teeths on g3
z_g4 = 25; % No of teeths on g4


w_c = 3.33; % Carrier frequency in Hz
w_s = (1+z_r/z_s)*w_c; % Sun frequency in Hz
w_m1 = z_r*w_c; % Meshing Frequency of the planetary gear
w_m2 = (1+z_r/z_s)*z_g1*w_c; % Meshing Frequency of first parallel gear
w_m3 = (1+z_r/z_s)*(z_g1/z_g2)*z_g3*w_c; % Meshing Frequency of second parallel gear

sample_freq = 2560; % Sampling Frequency

t = (0:1/sample_freq:1); % 1 seconds of data (time)


% Sun-Planetary gear signal over the first 3 harmonics
x_sp1 = vsp_11*cos(1*pi*w_m1*(t+(phi_1/(w_s-w_c)))) + vsp_12*cos(2*pi*w_m1*(t+(phi_1/(w_s-w_c)))) + vsp_13*cos(3*pi*w_m1*(t+(phi_1/(w_s-w_c))));
x_sp2 = vsp_11*cos(1*pi*w_m1*(t+(phi_2/(w_s-w_c)))) + vsp_12*cos(2*pi*w_m1*(t+(phi_2/(w_s-w_c)))) + vsp_13*cos(3*pi*w_m1*(t+(phi_2/(w_s-w_c))));
x_sp3 = vsp_11*cos(1*pi*w_m1*(t+(phi_3/(w_s-w_c)))) + vsp_12*cos(2*pi*w_m1*(t+(phi_3/(w_s-w_c)))) + vsp_13*cos(3*pi*w_m1*(t+(phi_3/(w_s-w_c))));

% Ring-Planetary gear signal over the first 3 harmonics
x_rp1 = vrp_11*cos(1*pi*w_m1*(t-(phi_1/w_c))) + vrp_12*cos(2*pi*w_m1*(t-(phi_1/w_c))) + vrp_13*cos(3*pi*w_m1*(t-(phi_1/w_c)));
x_rp2 = vrp_11*cos(1*pi*w_m1*(t-(phi_2/w_c))) + vrp_12*cos(2*pi*w_m1*(t-(phi_2/w_c))) + vrp_13*cos(3*pi*w_m1*(t-(phi_2/w_c)));
x_rp3 = vrp_11*cos(1*pi*w_m1*(t-(phi_3/w_c))) + vrp_12*cos(2*pi*w_m1*(t-(phi_3/w_c))) + vrp_13*cos(3*pi*w_m1*(t-(phi_3/w_c)));

% First Parallel gear signal
x_2 = v_21*cos(1*pi*w_m2*t);

% Second Parallel gear signal
x_3 = v_31*cos(1*pi*w_m3*t);

% Overall Signal
x_final = alpha_1*x_sp1 + alpha_1*x_sp2 + alpha_1*x_sp3 + x_rp1 + x_rp2 + x_rp3 + alpha_2*x_2 + alpha_3*x_3;

figure;
plot(t,x_final);


