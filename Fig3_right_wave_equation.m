% 2D Wave Equation Simulation using Bessel Functions (Analytical Solution)
% Parameters for the wave simulation
c = 1;           % Wave speed
Lx = 2;          % Length in x-direction
Ly = 2;          % Length in y-direction
Nx = 100;        % Number of points in x-direction
Ny = 100;        % Number of points in y-direction
Nt = 100;        % Increased number of time steps for smoother animation
tmax = 4;        % Maximum time
snapshot_time = 2.0; % Time to save snapshot image

% Wave parameters
amplitude = 1.0; % Wave amplitude
k = 2*pi*1.5;    % Wavenumber (related to frequency)

% Manual z-axis limits (set to [] for automatic calculation)
z_min = -0.6;    % Manual minimum z value
z_max = .95;     % Manual maximum z value

% Create spatial grid
x = linspace(-Lx/2, Lx/2, Nx);
y = linspace(-Ly/2, Ly/2, Ny);
[X, Y] = meshgrid(x, y);
r = sqrt(X.^2 + Y.^2);  % Radial distance

% Time vector with more points for slower animation
t = linspace(0, tmax, Nt);

% Pre-compute all time steps for smooth animation
phi_all = zeros(Ny, Nx, Nt);

% Use Bessel function of the first kind of order zero (J0)
% A superposition of Bessel functions is used to create the solution
for n = 1:Nt
    % Standing wave solution with Bessel function
    phi_all(:,:,n) = amplitude * besselj(0, k*r) .* cos(c*k*t(n));
end

% Calculate amplitude range for z-axis scaling if not manually set
if isempty(z_min) || isempty(z_max)
    max_phi = max(phi_all(:)) * 1.1; % 10% buffer
    min_phi = min(phi_all(:)) * 1.1;
else
    min_phi = z_min;
    max_phi = z_max;
end

% Create figure with enhanced visualization - larger figure size
figure('Position', [100, 100, 950, 700]);
set(gcf, 'Color', 'white', 'Renderer', 'painters');

% Set up axis with better proportions for plot vs colorbar
ax = axes('Position', [0.15 0.15 0.7 0.75]); % [left bottom width height]

% Create the initial surface plot
s = surf(X, Y, phi_all(:,:,1), 'FaceAlpha', 0.9, 'EdgeColor', 'none', 'FaceColor', 'interp');
colormap(jet);
shading interp;
lighting gouraud;
material([0.7 0.8 0.2 20 0.5]);

% Set fixed color limits
caxis([min_phi max_phi]);

% Add lights
delete(findall(gcf, 'Type', 'light'))
light('Position', [1, 1, 1], 'Style', 'infinite');
light('Position', [-1, -1, 1], 'Style', 'infinite', 'Color', [0.8, 0.8, 1]);

% Labels with increased padding from axes
xlabel('$x$', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'bold');
ylabel('$y$', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'bold');
zlabel('$\ln{(z)}$', 'Interpreter', 'latex', 'FontSize', 16, 'FontWeight', 'bold');

% Set fixed axes limits
xlim([-Lx/2, Lx/2]);
ylim([-Ly/2, Ly/2]);
zlim([min_phi, max_phi]);

% Set square proportions for x,y,z axes
axis manual;
pbaspect([1 1 0.8]);
daspect([1 1 0.8]);

% Add colorbar with improved positioning and label
cb = colorbar('Position', [0.86 0.15 0.03 0.75]);
cb.Label.String = 'Amplitude';
cb.Label.FontSize = 12;
cb.Label.FontWeight = 'bold';
cb.Label.Interpreter = 'latex';
set(cb, 'TickLabelInterpreter', 'latex', 'FontSize', 10);

% Adjust tick labels to prevent overlap
ax.XAxis.TickLabelGapOffset = 2;  % Move x-axis tick labels down
ax.YAxis.TickLabelGapOffset = 2;  % Move y-axis tick labels left
ax.ZAxis.TickLabelGapOffset = 2;  % Move z-axis tick labels right

% Prepare GIF file
gif_filename = 'wave_bessel_solution.gif';
delay_time = 0.2; % Increased delay between frames for slower animation

% Animation loop
snapshot_taken = false;
for n = 1:Nt
    % Update surface data
    set(s, 'ZData', phi_all(:,:,n));
    
    % Maintain fixed view properties
    caxis([min_phi max_phi]);
    
    % Capture frame for GIF (only if not the snapshot time)
    if abs(t(n) - snapshot_time) > tmax/Nt/2 % Not the exact snapshot time
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind, cm] = rgb2ind(im, 256);
        
        % Write to GIF
        if n == 1
            imwrite(imind, cm, gif_filename, 'gif', 'Loopcount', inf, 'DelayTime', delay_time);
        else
            imwrite(imind, cm, gif_filename, 'gif', 'WriteMode', 'append', 'DelayTime', delay_time);
        end
    end
    
    % Save snapshot at specified time
    if ~snapshot_taken && t(n) >= snapshot_time
        snapshot_filename = sprintf('wave_bessel_snapshot_t_%.2f.png', t(n));
        print('-dpng', '-r300', snapshot_filename);
        fprintf('Snapshot saved as %s\n', snapshot_filename);
        snapshot_taken = true;
    end
    
    % Pause for animation (longer pause for slower animation)
    pause(0.1);
end
fprintf('Animation saved as %s\n', gif_filename);