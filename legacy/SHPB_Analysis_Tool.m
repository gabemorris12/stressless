function varargout = SHPB_Analysis_Tool(varargin)
% SHPB_ANALYSIS_TOOL MATLAB code for SHPB_Analysis_Tool.fig
%      SHPB_ANALYSIS_TOOL, by itself, creates a new SHPB_ANALYSIS_TOOL or raises the existing
%      singleton*.
%
%      H = SHPB_ANALYSIS_TOOL returns the handle to a new SHPB_ANALYSIS_TOOL or the handle to
%      the existing singleton*.
%
%      SHPB_ANALYSIS_TOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SHPB_ANALYSIS_TOOL.M with the given input arguments.
%
%      SHPB_ANALYSIS_TOOL('Property','Value',...) creates a new SHPB_ANALYSIS_TOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SHPB_Analysis_Tool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SHPB_Analysis_Tool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SHPB_Analysis_Tool

% Last Modified by GUIDE v2.5 17-Jul-2017 15:54:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SHPB_Analysis_Tool_OpeningFcn, ...
                   'gui_OutputFcn',  @SHPB_Analysis_Tool_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

set(0,'DefaultTextInterpreter','none');
% End initialization code - DO NOT EDIT


% --- Executes just before SHPB_Analysis_Tool is made visible.
function SHPB_Analysis_Tool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SHPB_Analysis_Tool (see VARARGIN)

% uicontrol positions
handles.UIpositions = Remember_Positions(hObject);

% Choose default command line output for SHPB_Analysis_Tool
handles.output = hObject;

user_data = [];
user_data.dataset = [];
user_data.barsetup = [];

user_data.last_dir_load = [pwd '/']; % last load directory
user_data.last_dir_save = user_data.last_dir_load;  % last save directory

handles.user_data = user_data;

% initalize plot orders
handles.plotorder{1} = [4 8; 2 6; 14 16; 4 12; 2 10; 1 23];
handles.plotorder{2} = [4 8; 2 10; 14 16; 1 23];
handles.plotorder{3} = [4 8; 2 10];
handles.plotorder{4} = [4 8];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SHPB_Analysis_Tool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SHPB_Analysis_Tool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function UIpositions = Remember_Positions(hObject)
% get positions of UI controls

UIpositions = [];

% the list of UI controls 
objList = findobj( 'Type', 'uipanel', ...
    '-or', 'Tag', 'text2', ...
    '-or', 'Tag', 'popupmenu_dataset');

% add figure
objList = [hObject; objList];

for i=1:length(objList)
 
    % remember Units
    oldUnits = get(objList(i), 'Units');   
    % set Units temporarily to characters
    set(objList(i), 'Units', 'characters');
    
    tag = get(objList(i), 'Tag');
    UIpositions.(tag).Position = get(objList(i), 'Position');
    %display( sprintf('0 - %s: [x=%g y=%g w=%g h=%g]', tag, UIpositions.(tag).Position) )

    % restore Units
    set(objList(i), 'Units', oldUnits);
end


% --- Executes on selection change in popupmenu_dataset.
function popupmenu_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_dataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_dataset

focus = get(hObject,'Value');

if focus == 1
    % sample info box
    set(handles.edit_tag,       'String','')
    set(handles.edit_matl,      'String','')
    set(handles.edit_source,    'String','')
    set(handles.edit_notes,     'String','')
    set(handles.edit_strainrate,'String','')
    set(handles.radiobutton_compression,'Value',0)
    set(handles.radiobutton_tension,'Value',0)   
    
    % Sample Geometry Box
    set(handles.edit_length,'String','')
    set(handles.edit_area,'String','')
    set(handles.edit_diameter,'String','')
    
    % Voltage signal Editing Box
    set(handles.radiobutton_invert_i,'Value',0)
    set(handles.radiobutton_invert_t,'Value',0)
    set(handles.checkbox_null_i,'Value',0)
    set(handles.checkbox_null_t,'Value',0)
    set(handles.checkbox_rc,'Value',0)
    set(handles.checkbox_wc,'Value',0)
    
    % Dispersion Box
    set(handles.radiobutton_disp_p,'Value',0)
    set(handles.radiobutton_disp_m,'Value',0)
    
    % Bar Selection
    set(handles.popupmenu_i_bar,'Value',1)
    set(handles.popupmenu_t_bar,'Value',1)
        
else
    idx = focus - 1;
    dataset = handles.user_data.dataset(idx);
    
    % sample info box
    set(handles.edit_tag,       'String',dataset.tag)
    set(handles.edit_matl,      'String',dataset.material)
    set(handles.edit_source,    'String',dataset.source)
    set(handles.edit_notes,     'String',dataset.notes)
    set(handles.edit_strainrate,'String',num2str(dataset.strainrate))
       
    if dataset.stressstate == 0 % Set stress State 2 radio buttons
        set(handles.radiobutton_tension,'Value',0)
        set(handles.radiobutton_compression,'Value',1)
    elseif dataset.stressstate == 1
        set(handles.radiobutton_tension,'Value',1)
        set(handles.radiobutton_compression,'Value',0)
    else 
        set(handles.radiobutton_tension,'Value',0)
        set(handles.radiobutton_compression,'Value',0)
    end
    
    % Sample Geometry Box
    set(handles.edit_length,'String',num2str(dataset.length))
    set(handles.edit_area,'String',num2str(dataset.area))
    diameter = 2*sqrt(dataset.area/pi);
    set(handles.edit_diameter,'String',num2str(diameter))
    
    % Voltage signal Editing Box
    if dataset.null_I == 0 % Checkboxes to show if nulling has occurred for incident bar gage
        set(handles.checkbox_null_i,'Value',0)
    else
        set(handles.checkbox_null_i,'Value',1)
    end
    
    if dataset.null_T == 0 % Checkboxes to show if nulling has occurred for transmitted bar gage
        set(handles.checkbox_null_t,'Value',0)
    else
        set(handles.checkbox_null_t,'Value',1)
    end
    
    set(handles.radiobutton_invert_i,'Value',dataset.invert_i)
    set(handles.radiobutton_invert_t,'Value',dataset.invert_t)
    
    if isempty(dataset.inc_idx)
        set(handles.checkbox_wc,'Value',0)
    else
        set(handles.checkbox_wc,'Value',1)
    end
    
    if isempty(dataset.rough_crop_indicies)
        set(handles.checkbox_rc,'Value',0)
    else
        set(handles.checkbox_rc,'Value',1)
    end
    
    
    % Dispersion Box
    if any(dataset.dispersion_pre)
        set(handles.radiobutton_disp_p,'Value',1)
        set(handles.radiobutton_disp_m,'Value',0)
        set(handles.popupmenu_disp,'Value',dataset.dispersion_pre + 1) % account for '(select)'
    elseif any(dataset.dispersion_man)
        set(handles.radiobutton_disp_p,'Value',0)
        set(handles.radiobutton_disp_m,'Value',1)
    end
        
    % Bar Selection incident
    if isempty(dataset.bar_i_idx) 
        set(handles.popupmenu_i_bar,'Value',1)
    else
        set(handles.popupmenu_i_bar,'Value',1 + dataset.bar_i_idx) % account for '(select)'
    end
    
    % Bar Selection transmitted
    if isempty(dataset.bar_t_idx) 
        set(handles.popupmenu_t_bar,'Value',1)
    else
        set(handles.popupmenu_t_bar,'Value',1 + dataset.bar_t_idx)
    end
end
    c= uicontextmenu;
    uimenu(c,'Label','Isolate (Plot)','Callback',{@plot_opts, 'isolate'});
    uimenu(c,'Label','(un)Isolate Any (Plot)','Callback',{@plot_opts, 'unisolate'});
    uimenu(c,'Label','Disable (Plot)','Callback',{@plot_opts, 'disable'});
    uimenu(c,'Label','Enable (Plot)','Callback',{@plot_opts, 'enable'});
    uimenu(c,'Label','Delete','Callback',{@plot_opts, 'delete'},'Separator','on');
    set(hObject, 'UIContextMenu', c)

    
% Update handles structure
guidata(hObject, handles);


function plot_opts(hObject, event, method)
% pull in handles
handles = guidata(hObject);

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
    return
end

% Setup Dataset
idx = focus - 1;

switch method
    case 'isolate'
        for i = 1:length(handles.user_data.dataset)
            handles.user_data.dataset(i).plotiso = 0;
        end
        handles.user_data.dataset(idx).plotiso = 1;
    case 'unisolate'
        for i = 1:length(handles.user_data.dataset)
            handles.user_data.dataset(i).plotiso = 0;
        end
    case 'disable'
        handles.user_data.dataset(idx).plotvisability = 0;
    case 'enable'
        handles.user_data.dataset(idx).plotvisability = 1;
    case 'delete'
        handles.user_data.dataset(idx) = [];
        datasetnames = get(handles.popupmenu_dataset,'String'); 
        datasetnames(focus) = [];
        set(handles.popupmenu_dataset,'String',datasetnames)
        set(handles.popupmenu_dataset,'Value',1)
        % Clear all other boxes
        set(handles.edit_tag,'String','')
        set(handles.edit_matl,'String','')
        set(handles.edit_source,'String','')
        set(handles.edit_notes,'String','')
        set(handles.edit_strainrate,'String','')
        set(handles.radiobutton_compression,'Value',0)
        set(handles.radiobutton_tension,'Value',0)   
        set(handles.edit_length,'String','')
        set(handles.edit_area,'String','')
        set(handles.edit_diameter,'String','')
        set(handles.radiobutton_invert_i,'Value',0)
        set(handles.radiobutton_invert_t,'Value',0)
        set(handles.checkbox_null_i,'Value',0)
        set(handles.checkbox_null_t,'Value',0)
        set(handles.checkbox_rc,'Value',0)
        set(handles.checkbox_wc,'Value',0)
        set(handles.radiobutton_disp_p,'Value',0)
        set(handles.radiobutton_disp_m,'Value',0)
        set(handles.popupmenu_i_bar,'Value',1)
        set(handles.popupmenu_t_bar,'Value',1)
end

% Update handles structure
guidata(hObject, handles);
        



% --- Executes during object creation, after setting all properties.
function popupmenu_dataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_crop.
function pushbutton_crop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearplots(hObject,1,1)

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
    return
end

% plot and retrive points
idx = focus - 1;
dataset = handles.user_data.dataset(idx);
uiwait(msgbox('Click on two locations on the plot to bracket the data','Rough Crop Instructions','modal'));


% function to determine whether or not to invert the signal
I_fact = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
T_fact = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% Plot
axes('Parent', handles.Plot_panel)
cla;
subplot(1,1,1)
plot(dataset.volt_raw_I*I_fact)
hold on
plot(dataset.volt_raw_T*T_fact)
xlabel('Number of sampling points')
ylabel('Raw Voltages')
hold off
[x,~] = ginput(2);

x_low = max([1 ceil(min(x))]);
x_high = min([floor(max(x)) length(dataset.volt_raw_T)]);

axes('Parent', handles.Plot_panel)
cla;
subplot(1,1,1)
plot(dataset.volt_raw_I(x_low:x_high)*I_fact)
hold on
plot(dataset.volt_raw_T(x_low:x_high)*T_fact)
xlabel('Number of sampling points')
ylabel('Raw Voltages')
hold off

% Construct a questdlg with three options
choice = questdlg('Next step...','Rough Crop','Accept','Refine','Remove','Accept');

% Handle response
switch choice % Accept the initial crop
    case 'Accept'
        dataset.rough_crop_indicies = [x_low x_high];
        cla reset
        axis off
        set(handles.checkbox_rc,'Value',1) % check the box for completion
    case 'Refine' % Take the 1st group of cropped data, and crop again
        uiwait(msgbox('Click on two locations on the plot to bracket the data','Rough Crop Instructions','modal'));
        [x2,~] = ginput(2);
        x_low2 = max([x_low (ceil(min(x2))+x_low)]);
        x_high2 = min([(floor(max(x2))+x_low) x_high]);
        dataset.rough_crop_indicies = [x_low2 x_high2];

        axes('Parent', handles.Plot_panel)
        cla;
        subplot(1,1,1)
        plot(dataset.volt_raw_I(x_low2:x_high2)*I_fact)
        hold on
        plot(dataset.volt_raw_T(x_low2:x_high2)*T_fact)
        xlabel('Number of sampling points')
        ylabel('Raw Voltages')
        hold off
        uiwait(msgbox('Crop Refined','Rough Crop Instructions','modal'));
        cla reset
        axis off
        set(handles.checkbox_rc,'Value',1) % check the box for completion
    case 'Remove' % Remove the cropped indicies
        dataset.rough_crop_indicies = [];
        cla reset
        axis off
end
handles.user_data.dataset(idx) = dataset;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_null_I.
function pushbutton_null_I_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_null_I (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearplots(hObject,1,1)

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Crop Error','modal'));
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

uiwait(msgbox('Click on two locations in the plot that brackets the portion of the signal to be used to calculate an averaged null value.','Rough Crop Instructions','modal'));

% function to determine whether or not to invert the signal
I_fact = dataset.invert_i*(-2)+1;

% If no rough crop completed, display entire signal
if isempty(dataset.rough_crop_indicies) 
    axes('Parent', handles.Plot_panel)
    cla;
    subplot(1,1,1)
    plot(dataset.volt_raw_I*I_fact)
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    [x,~] = ginput(2); 
    x_low = max([1 ceil(min(x))]);
    x_high = min([floor(max(x)) length(dataset.volt_raw_I)]);
else % display signal from rough crop
    cp_idx = dataset.rough_crop_indicies;
    axes('Parent', handles.Plot_panel)
    cla;
    subplot(1,1,1)
    plot(dataset.volt_raw_I(cp_idx(1):cp_idx(2))*I_fact)
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    [x_cp,~] = ginput(2); 
    x = cp_idx(1) + x_cp;
    x_low = max([1 ceil(min(x))]);
    x_high = min([floor(max(x)) length(dataset.volt_raw_I)]);
end

% in case the same point is clicked twice
if x_low == x_high
    x_high = x_high + 1; 
end

% Take Average
dataset.null_I = mean(dataset.volt_raw_I(x_low:x_high)); 

% Remove Active Plot
axes('Parent', handles.Plot_panel)
cla reset
axis off

% Plot Results
if isempty(dataset.rough_crop_indicies) % no rough crop completed 
    subplot(2,1,1)
    plot(dataset.volt_raw_I*I_fact)
    hold on
    plot((dataset.volt_raw_I - dataset.null_I)*I_fact)
    legend('Raw Data','Offset Applied')
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    title('Nulled Selected area (offset)')
    hold off
else % rough crop completed 
    subplot(2,1,1)
    plot(dataset.volt_raw_I(x_low:x_high)*I_fact)
    hold on
    plot((dataset.volt_raw_I(x_low:x_high) - dataset.null_I)*I_fact)
    legend('Raw Data','Offset Applied')
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    title('Nulled Selected area (offset)')
    hold off
end

% zoomed in plot
subplot(2,1,2)
plot_idx = [max([1 (x_low-200)]) min([x_high+200 length(dataset.volt_raw_I)])];
plot(dataset.volt_raw_I(plot_idx(1):plot_idx(2))*I_fact)
hold on
plot((dataset.volt_raw_I(plot_idx(1):plot_idx(2)) - dataset.null_I)*I_fact)
legend('Raw Data','Offset Applied')
xlabel('Number of sampling points')
ylabel('Raw Voltages')
title('Expanded Area (offset)')
hold off

string_offset = ['Value offset/nulled:' num2str(dataset.null_I*I_fact)];
uiwait(msgbox(string_offset,'Result','modal'));

% Clear Plots
for i=1:2
    subplot(2,1,i)
    cla reset
    axis off
end

handles.user_data.dataset(idx) = dataset;
set(handles.checkbox_null_i,'Value',1)

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in pushbutton_null_T.
function pushbutton_null_T_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_null_T (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearplots(hObject,1,1)

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Crop Error','modal'));
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

uiwait(msgbox('Click on two locations in the plot that brackets the portion of the signal to be used to calculate an averaged null value.','Rough Crop Instructions','modal'));

% function to determine whether or not to invert the signal
T_fact = dataset.invert_t*(-2)+1;

% If no rough crop completed, display entire signal
if isempty(dataset.rough_crop_indicies) 
    axes('Parent', handles.Plot_panel)
    cla;
    subplot(1,1,1)
    plot(dataset.volt_raw_T*T_fact)
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    [x,~] = ginput(2); 
    x_low = max([1 ceil(min(x))]);
    x_high = min([floor(max(x)) length(dataset.volt_raw_T)]);
else % display signal from rough crop
    cp_idx = dataset.rough_crop_indicies;
    axes('Parent', handles.Plot_panel)
    cla;
    subplot(1,1,1)
    plot(dataset.volt_raw_T(cp_idx(1):cp_idx(2))*T_fact)
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    [x_cp,~] = ginput(2); 
    x = cp_idx(1) + x_cp;
    x_low = max([1 ceil(min(x))]);
    x_high = min([floor(max(x)) length(dataset.volt_raw_T)]);
end

% Take Average
dataset.null_T = mean(dataset.volt_raw_T(x_low:x_high)); 

% Remove Active Plot
axes('Parent', handles.Plot_panel)
cla reset
axis off

% Plot Results
if isempty(dataset.rough_crop_indicies) % no rough crop completed 
    subplot(2,1,1)
    plot(dataset.volt_raw_T*T_fact)
    hold on
    plot((dataset.volt_raw_T - dataset.null_T)*T_fact)
    legend('Raw Data','Offset Applied')
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    title('Nulled Selected area (offset)')
    hold off
else % rough crop completed 
    subplot(2,1,1)
    plot(dataset.volt_raw_T(x_low:x_high)*T_fact)
    hold on
    plot((dataset.volt_raw_T(x_low:x_high) - dataset.null_T)*T_fact)
    legend('Raw Data','Offset Applied')
    xlabel('Number of sampling points')
    ylabel('Raw Voltages')
    title('Nulled Selected area (offset)')
    hold off
end

% zoomed in plot
subplot(2,1,2)
plot_idx = [max([1 (x_low-200)]) min([x_high+200 length(dataset.volt_raw_T)])];
plot(dataset.volt_raw_T(plot_idx(1):plot_idx(2))*T_fact)
hold on
plot((dataset.volt_raw_T(plot_idx(1):plot_idx(2)) - dataset.null_T)*T_fact)
legend('Raw Data','Offset Applied')
xlabel('Number of sampling points')
ylabel('Raw Voltages')
title('Expanded Area (offset)')
hold off

string_offset = ['Value offset/nulled:' num2str(dataset.null_T*T_fact)];
uiwait(msgbox(string_offset,'Result','modal'));

% Clear Plots
for i=1:2
    subplot(2,1,i)
    cla reset
    axis off
end

handles.user_data.dataset(idx) = dataset;
set(handles.checkbox_null_t,'Value',1)

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_waveclipping.
function pushbutton_waveclipping_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_waveclipping (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clearplots(hObject,1,1)

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Wave Clipping Error','modal'));
    return
end

% index
idx = focus - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);

% force users to null data prior to clipping 
if dataset.null_I == 0 || dataset.null_T == 0
    uiwait(errordlg('Please complete signal nulling step and try again.','Wave Clipping Error','modal'));
    return
end

% force users to crop data prior to clipping 
if isempty(dataset.rough_crop_indicies)
    uiwait(errordlg('Please complete rough crop step and try again.','Wave Clipping Error','modal'));
    return
end

% Need bar properties applied
ibaridx = dataset.bar_i_idx;
tbaridx = dataset.bar_t_idx;

% check to see if users have applied a bar(s) to a dataset
if isempty(dataset.bar_i_idx) || isempty(dataset.bar_t_idx) || dataset.bar_t_idx==0 || dataset.bar_i_idx==0
    uiwait(errordlg('Please select incident & transmitted bars prior to wave clipping.','Wave Clipping Error','modal'));
    return
end

% Setup bar structures
barsetup_i = handles.user_data.barsetup(ibaridx);
barsetup_t = handles.user_data.barsetup(tbaridx);

% Need to have same sampling rate for each gage
if barsetup_i.samplefreq ~= barsetup_t.samplefreq
    uiwait(errordlg('Incident and Transmitted bars have different sampling rates.','Wave Clipping Error','modal'));
    return
end

% initial indicies
clow = dataset.rough_crop_indicies(1);
chigh = dataset.rough_crop_indicies(2);

% initialize clipping start indicies [incident reflected transmitted]
len = (chigh-clow);

if isempty(dataset.inc_idx)
    idx_st = [floor(0.1*len),floor(0.5*(len)),floor(0.1*len)];
    pulse_width = floor(0.2*len);
else
    idx_st = [dataset.inc_idx, dataset.refl_idx, dataset.trans_idx] - clow;
    pulse_width = dataset.wave_length;
end

% Function call to plot calculated values
replot_clips(hObject,idx_st,pulse_width)

% Create sliders
sldmax = len-pulse_width;
sld_i = uicontrol('Parent', handles.Plot_panel,'Style', 'slider',...
    'Min',1,'Max',sldmax,'Value',idx_st(1),...
    'Units','normalized','Tag','slider_i','SliderStep',[1 10]/sldmax,...
    'Position', [.1 0 .185 .025],...
    'backgroundcolor',[60 145 201]/256,...
    'Callback', {@sliderupdate,hObject,len}); 

sld_r = uicontrol('Parent', handles.Plot_panel,'Style', 'slider',...
    'Min',1,'Max',sldmax,'Value',idx_st(2),...
    'Units','normalized','Tag','slider_r','SliderStep',[1 10]/sldmax,...
    'Position', [.305 0 .185 .025],...
    'backgroundcolor',[224 132 93]/256,...
    'Callback', {@sliderupdate,hObject,len}); 

sld_t = uicontrol('Parent', handles.Plot_panel,'Style', 'slider',...
    'Min',1,'Max',sldmax,'Value',idx_st(3),...
    'Units','normalized','Tag','slider_t','SliderStep',[1 10]/sldmax,...
    'Position', [.51 0 .185 .025],...
    'backgroundcolor',[153 187 108]/256,...
    'Callback', {@sliderupdate,hObject,len}); 

sld_l = uicontrol('Parent', handles.Plot_panel,'Style', 'slider',...
    'Min',1,'Max',floor(len/2),'Value',pulse_width,...
    'Units','normalized','Tag','slider_l','SliderStep',[1 10]/sldmax,...
    'Position', [.715 0 .185 .025],...
    'backgroundcolor',[200 200 200]/256,...    
    'Callback', {@sliderupdate,hObject,len}); 

% Add a text uicontrol to label the slider.
txt_i = uicontrol('Parent', handles.Plot_panel,'Style','text',...
    'Units','normalized','Position',[.1 .026 .2 .016],'HorizontalAlignment', 'center',...
    'String','Incident');

txt_r = uicontrol('Parent', handles.Plot_panel,'Style','text',...
    'Units','normalized','Position',[.3 .026 .2 .016],'HorizontalAlignment', 'center',...
    'String','Reflected');

txt_t = uicontrol('Parent', handles.Plot_panel,'Style','text',...
    'Units','normalized','Position',[.5 .026 .2 .016],'HorizontalAlignment', 'center',...
    'String','Transmitted');

txt_l = uicontrol('Parent', handles.Plot_panel,'Style','text',...
    'Units','normalized','Position',[.7 .026 .2 .016],'HorizontalAlignment', 'center',...
    'String','Pulse Width');

% Create push button
cancel = uicontrol('Parent', handles.Plot_panel,'Style', 'pushbutton', 'String', 'Cancel',...
    'Units','normalized','Position',[0 0 .07 .03],...
    'Callback', {@clearplots,hObject});   
autoalign = uicontrol('Parent', handles.Plot_panel,'Style', 'pushbutton', 'String', 'Auto Align',...
    'Units','normalized','Position',[0 .125 .07 .03],...
    'Callback', {@align,hObject,len,1});  
align_inc = uicontrol('Parent', handles.Plot_panel,'Style', 'pushbutton', 'String', 'Align to Inc',...
    'Units','normalized','Position',[0 .09 .07 .03],...
    'Callback', {@align,hObject,len,2});  
accept = uicontrol('Parent', handles.Plot_panel,'Style', 'pushbutton', 'String', 'Accept',...
    'Units','normalized','Position',[0 .035 .07 .03],...
    'Callback', {@acceptfun,hObject});  

    
function align(source,event,hObject,len,alignchoice)
handles = guidata(hObject);   

%set index/focus
idx = get(handles.popupmenu_dataset,'Value') - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);

% Setup bar structures
barsetup_i = handles.user_data.barsetup(dataset.bar_i_idx);
barsetup_t = handles.user_data.barsetup(dataset.bar_t_idx);

% function to determine whether or not to invert the signal
fact_i = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
fact_t = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% cropped indicies
clow = dataset.rough_crop_indicies(1);
chigh = dataset.rough_crop_indicies(2);

% nulled values
null_i = dataset.null_I;
null_t = dataset.null_T;

% cropped voltages
volt_i = dataset.volt_raw_I(clow:chigh);
volt_t = dataset.volt_raw_T(clow:chigh);

% Gage Factors
gf_i = barsetup_i.gagefactor;
gf_t = barsetup_t.gagefactor;

% Cropped, (inverted), and nulled, strains
strain_i = (volt_i - null_i) * fact_i * gf_i;
strain_t = (volt_t - null_t) * fact_t * gf_t;

% create time array
freq = barsetup_i.samplefreq;
time = (0:length(strain_i)-1)/(freq*10^6);

% auto align feature
if alignchoice == 1 % this section attepts to find the incident wave and then align other 2 waves
    if ~license('test', 'Signal_Toolbox')
       uiwait(errordlg('Auto Alignment uses Signal Processing Toolbox functions. That toolbox is not installed in your version of Matlab','Need Signal Processing Toolbox','modal'));
       return
    end

    % Built in signal processing function to find overshoots
    [~,~,OSINST] = overshoot(strain_i',time); % from signal processing toolbox

    pt1 = find(time == OSINST(1));
    pt2 = find(time == OSINST(2));

    % start 30 pts prior to beginning
    pad = 30;

    % index for inc wave
    idx_st(1) = max([pt1 - pad,1]);

    % calc pulse width/time
    pulse_width = pt2 - idx_st(1);
    
    % pulse width cannoth be greater than twice the length of the signal
    if pulse_width*2 > len
        pulse_width = floor(len/2);
    end
elseif alignchoice == 2 % this aligns to the user defined incident wave
    s_i=findobj('Parent', handles.Plot_panel,'Tag','slider_i');
    s_l=findobj('Parent', handles.Plot_panel,'Tag','slider_l');
    
    idx_st(1)   = get(s_i,'Value');
    pulse_width = get(s_l,'Value');
end
    
% calc end index for inc wave
idx_end(1) = idx_st(1) + pulse_width;

inc_wave = [time(idx_st(1):idx_end(1))' strain_i(idx_st(1):idx_end(1))];

% calculate the remaining increments
inc_rem = length(idx_st(1):(length(strain_i)-pulse_width)); 
if ~license('test', 'Optimization_Toolbox') || inc_rem < 150 % no need to run ga for small sets
    % setup error matrix
    err = zeros(inc_rem,inc_rem);

    %waitbar
    wtb = waitbar(0,'Please wait...');
    % Loop to find all summation of errors for wave alignment
    for i=1:inc_rem
        waitbar(i / inc_rem)
        for j=1:inc_rem
            st_pt2  = (i-1)+idx_st(1);
            st_pt3  = (j-1)+idx_st(1);
            wave2 = strain_i(st_pt2:st_pt2+pulse_width);
            wave3 = strain_t(st_pt3:st_pt3+pulse_width);
            err(i,j) = sum(abs(inc_wave(:,2) + wave2 - wave3));
        end
    end
    close(wtb)

    % Located min error value
    [~,I] = min(err(:));
    [I_row, I_col] = ind2sub(size(err),I);

    % set start indicies
    idx_st(2)  = I_row+idx_st(1)-1;
    idx_st(3)  = I_col+idx_st(1)-1;
   
else
    % create handle to the objective function
    objFn = @(z) align_objective_function(z,idx_st(1),pulse_width,inc_rem,...
        strain_i,strain_t,inc_wave(:,2));

    % run optimization
   h = msgbox(['Please wait. Using ga (genetic algorithm) to find optimal wave alignment. ' ...
       'Message will automatically go away when complete.'], ...
       'Align Waves', 'help', 'modal');

    % Define objective function
    objFn = @(z) align_objective_function(z,pulse_width,strain_i,strain_t,inc_wave(:,2));
    
    % define bounds and options
    LB = repmat(idx_st(1),1,2);
    UB = LB+inc_rem-1;
    options = gaoptimset('Display', 'iter','PlotFcns', @gaplotbestf);
    
    % run optimization (Genetic Algorithm).
    x = ga(objFn,2,[],[],[],[],LB,UB,[],[1 2],options);
        
    % set start indicies
    idx_st(2:3) = x; 
    
    % close message window
    if ishandle(h), delete(h); end
    %display(Output.message)
    
    % delete PlotFn plot if any
    h = findobj('Name', 'Genetic Algorithm');
    if ishandle(h), close(h), end
end
  
% Find sliders
s_i=findobj('Parent', handles.Plot_panel,'Tag','slider_i');
s_r=findobj('Parent', handles.Plot_panel,'Tag','slider_r');
s_t=findobj('Parent', handles.Plot_panel,'Tag','slider_t');
s_l=findobj('Parent', handles.Plot_panel,'Tag','slider_l');

sldmax = len - pulse_width;
    
% index values can be greater than the end index minus the pulse 
idx_st(idx_st>=sldmax) = sldmax;

% Reset the sliders with updated values
set(s_i,'Value',idx_st(1),'Max',sldmax,'SliderStep',[1 10]/sldmax)
set(s_r,'Value',idx_st(2),'Max',sldmax,'SliderStep',[1 10]/sldmax)
set(s_t,'Value',idx_st(3),'Max',sldmax,'SliderStep',[1 10]/sldmax)
set(s_l,'Value',pulse_width)

% Function call to plot calculated values
replot_clips(hObject,idx_st,pulse_width)


function y = align_objective_function(x,pw,s_i,s_t,w1)
% minimize diff in wave alignment

% x       index values to be found (ga option chosen to limit x to integers)
% pw      pulse/wave width
% s_i     strain values in incident bar
% s_t     strain values in transmitted bar
% w1      incident wave

wave2 = s_i(x(1):x(1)+pw);
wave3 = s_t(x(2):x(2)+pw);
y = sum(abs(w1 + wave2 - wave3));
    
    
function acceptfun(hObject,source,event)
handles = guidata(hObject); 

% Need to determine if the test is in tension or compression. So will
% average the values from the incident wave and transmitted wave and verify
% the sign is the same
%set index
idx = get(handles.popupmenu_dataset,'Value') - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);

% Setup bar structures
barsetup_i = handles.user_data.barsetup(dataset.bar_i_idx);
barsetup_t = handles.user_data.barsetup(dataset.bar_t_idx);

% function to determine whether or not to invert the signal
fact_i = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
fact_t = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% cropped indicies
clow = dataset.rough_crop_indicies(1);
chigh = dataset.rough_crop_indicies(2);

% nulled values
null_i = dataset.null_I;
null_t = dataset.null_T;

% cropped voltages
volt_i = dataset.volt_raw_I(clow:chigh);
volt_t = dataset.volt_raw_T(clow:chigh);

% Gage Factors
gf_i = barsetup_i.gagefactor;
gf_t = barsetup_t.gagefactor;

% Cropped, (inverted), and nulled, strains
strain_i = (volt_i - null_i) * fact_i * gf_i;
strain_t = (volt_t - null_t) * fact_t * gf_t;

% Find all the slider locations
s_i=findobj('Parent', handles.Plot_panel,'Tag','slider_i');
s_r=findobj('Parent', handles.Plot_panel,'Tag','slider_r');
s_t=findobj('Parent', handles.Plot_panel,'Tag','slider_t');
s_l=findobj('Parent', handles.Plot_panel,'Tag','slider_l');

idx_st(1)   = get(s_i,'Value');
idx_st(2)   = get(s_r,'Value');
idx_st(3)   = get(s_t,'Value');
pulse_width = get(s_l,'Value');

% initialize clipping end indicies [incident reflected transmitted]
idx_end = idx_st+pulse_width;

% create wave arrays
inc_avg = mean(strain_i(idx_st(1):idx_end(1)));
tra_avg = mean(strain_t(idx_st(3):idx_end(3)));

if inc_avg*tra_avg<0
    uiwait(errordlg({'Waves inverted incorrectly. Both Incident and ' ...
        ' Transmitted Wave must be in the same orientation.' ...
        ' (e.g. both negative or both positive)'},'Wave sign inconsistant','modal'));
    return
end

% Verify w/ user the stress state
if inc_avg < 0
    choice = questdlg(['The negative wave pulse show that the specimen ' ...
    'stress state was COMPRESSION. Please Confirm to continue'], ...
    'Compressive Stress State?','Confirm','Cancel','Cancel');

    % Handle response
    switch choice 
        case 'Confirm'
        case 'Cancel' 
            return
    end
    dataset.stressstate = 0;
    set(handles.radiobutton_compression,'Value',1)
    set(handles.radiobutton_tension,'Value',0)
else
    choice = questdlg(['The positive wave pulse shows that the specimen ' ...
    'stress state was TENSION. Please Confirm to continue'], ...
    'Tensile Stress State?','Confirm','Cancel','Cancel');

    % Handle response
    switch choice 
        case 'Confirm'
        case 'Cancel' 
            return
    end
    dataset.stressstate = 1;
    set(handles.radiobutton_tension,'Value',1)
    set(handles.radiobutton_compression,'Value',0)
end

% Pass slider locations to handles   
st_pts = idx_st + dataset.rough_crop_indicies(1);

dataset.inc_idx     = st_pts(1); 
dataset.refl_idx    = st_pts(2); 
dataset.trans_idx   = st_pts(3); 
dataset.wave_length = pulse_width;

handles.user_data.dataset(idx) = dataset;

% check the box for completion
set(handles.checkbox_wc,'Value',1)

% Update handles structure
guidata(hObject, handles);

clearplots(hObject,source,event)
    
function clearplots(hObject,source,event)
    handles = guidata(hObject);
    h=findobj('Parent', handles.Plot_panel);
    delete(h)
    
function sliderupdate(hObject,source,event,len)
 
       handles = guidata(hObject); 
    
    s_i=findobj('Parent', handles.Plot_panel,'Tag','slider_i');
    s_r=findobj('Parent', handles.Plot_panel,'Tag','slider_r');
    s_t=findobj('Parent', handles.Plot_panel,'Tag','slider_t');
    s_l=findobj('Parent', handles.Plot_panel,'Tag','slider_l');
      
    idx_st(1)   = round(get(s_i,'Value'));
    idx_st(2)   = round(get(s_r,'Value'));
    idx_st(3)   = round(get(s_t,'Value'));
    pulse_width = round(get(s_l,'Value'));
    
    sldmax = len-pulse_width;
    
    % index values can be greater than the end index minus the pulse 
    idx_st(idx_st>=sldmax) = sldmax;
    
    % Reset the sliders with updated values
    set(s_i,'Value',idx_st(1),'Max',sldmax,'SliderStep',[1 10]/sldmax)
    set(s_r,'Value',idx_st(2),'Max',sldmax,'SliderStep',[1 10]/sldmax)
    set(s_t,'Value',idx_st(3),'Max',sldmax,'SliderStep',[1 10]/sldmax)
    set(s_l,'Value',pulse_width)
    % Function call to plot calculated values
    replot_clips(hObject,idx_st,pulse_width)
    
function replot_clips(hObject,idx_st,pulse_width)

handles = guidata(hObject); 

%set index
idx = get(handles.popupmenu_dataset,'Value') - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);

% Setup bar structures
barsetup_i = handles.user_data.barsetup(dataset.bar_i_idx);
barsetup_t = handles.user_data.barsetup(dataset.bar_t_idx);

% function to determine whether or not to invert the signal
fact_i = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
fact_t = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% cropped indicies
clow = dataset.rough_crop_indicies(1);
chigh = dataset.rough_crop_indicies(2);

% nulled values
null_i = dataset.null_I;
null_t = dataset.null_T;

% cropped voltages
volt_i = dataset.volt_raw_I(clow:chigh);
volt_t = dataset.volt_raw_T(clow:chigh);

% Gage Factors
gf_i = barsetup_i.gagefactor;
gf_t = barsetup_t.gagefactor;

% Cropped, (inverted), and nulled, strains
strain_i = (volt_i - null_i) * fact_i * gf_i;
strain_t = (volt_t - null_t) * fact_t * gf_t;

% Bar Properties
area_i = (barsetup_i.diameter)^2 * 0.25 * pi;
area_t = (barsetup_t.diameter)^2 * 0.25 * pi;

mod_i  = barsetup_i.modulus;
mod_t  = barsetup_t.modulus;

wspeed_i = barsetup_i.wavespeed;
wspeed_t = barsetup_t.wavespeed;

% initialize clipping end indicies [incident reflected transmitted]
idx_end = idx_st+pulse_width;

% create time array
freq = barsetup_i.samplefreq;
time = (0:length(strain_i)-1)/(freq*10^6);
pulse_time = (0:pulse_width)/(freq*10^6);

% create wave arrays
inc_wave = [time(idx_st(1):idx_end(1))' strain_i(idx_st(1):idx_end(1))];
ref_wave = [time(idx_st(2):idx_end(2))' strain_i(idx_st(2):idx_end(2))];
tra_wave = [time(idx_st(3):idx_end(3))' strain_t(idx_st(3):idx_end(3))];

%run dispersion if activated:
if any(dataset.dispersion_pre) || any(dataset.dispersion_man)
    
    if dataset.dispersion_pre ~=0
        const = [0.5875 , 0.41473, 41.305, 12.208, -9.4836, 3.0893; ...
                 0.58626, 0.41589, 38.715, 13.257, -9.3202, 3.0344; ...
                 0.58499, 0.41708, 36.051, 14.339, -9.1552, 2.9774; ...
                 0.58367, 0.41832, 33.312, 15.458, -8.9934, 2.9202; ...
                 0.58232, 0.41958, 30.564, 16.551, -8.8078, 2.8552; ...
                 0.58092, 0.42088, 27.792, 17.636, -8.6088, 2.7857; ...
                 0.57972, 0.42201, 26.257, 18.005, -8.2969, 2.7116; ...
                 0.5785,  0.42315, 24.674, 18.385, -7.9743, 2.6328; ...
                 0.57724, 0.42434, 23.039, 18.79,  -7.6529, 2.5538; ...
                 0.57594, 0.42555, 21.326, 19.224, -7.3258, 2.4713; ...
                 0.5746,  0.42681, 19.53,  19.702, -7.0054, 2.3897; ...
                 0.57344, 0.4279,  18.668, 19.664, -6.6213, 2.3118; ...
                 0.57228, 0.42901, 17.781, 19.636, -6.2337, 2.2327; ...
                 0.57106, 0.43016, 16.764, 19.679, -5.8543, 2.1532; ...
                 0.56983, 0.43132, 15.741, 19.714, -5.4671, 2.0717; ...
                 0.56855, 0.43254, 14.602, 19.809, -5.0851, 1.9895];
        c_val = const(dataset.dispersion_pre,:); 
    else
        c_val = dataset.dispersion_man;
    end
    time_inc = 1 / (barsetup_i.samplefreq*10^6); % (in sec) 
    a_i = barsetup_i.diameter / 1000; % (in meters)
    a_t = barsetup_t.diameter / 1000; % (in meters)
    dist_i = time_inc * 0.5 * barsetup_i.wavespeed * (idx_st(2) - idx_st(1)); % (in meters)
    dist_t = time_inc * (idx_st(3)*barsetup_t.wavespeed - idx_st(1)*barsetup_i.wavespeed) - dist_i; 
    inc_wave(:,2) = applyDispersionCorrection(inc_wave(:,2),time_inc,a_i,dist_i,wspeed_i,c_val,1);
    ref_wave(:,2) = applyDispersionCorrection(ref_wave(:,2),time_inc,a_i,dist_i,wspeed_i,c_val,0);
    tra_wave(:,2) = applyDispersionCorrection(tra_wave(:,2),time_inc,a_t,dist_t,wspeed_t,c_val,0);
end

% Force calculation (kN)
force_i = area_i * mod_i * (inc_wave(:,2) + ref_wave(:,2)) * 10^(-3);
force_t = area_t * mod_t * tra_wave(:,2) * 10^(-3);
force_3 = (force_i+force_t)/2;

% Velocity calculations (m/s)
vel_3 = wspeed_i*(inc_wave(:,2) - ref_wave(:,2)) - wspeed_t*tra_wave(:,2);
vel_1 = -2*wspeed_i*ref_wave(:,2);

% Displacement calculations (mm)
dt = 1 / (barsetup_i.samplefreq*10^6);
disp_3 = cumtrapz(vel_3) * dt * 1000;
disp_1 = cumtrapz(vel_1) * dt * 1000;

% Create a figure and axes
axes('Parent', handles.Plot_panel)

% Define Colors
c1 = [0 114 190]/256;
c2 = [218 83 25]/256;
c3 = [119 173 48]/256;

% change time to ms for plots
time_p = pulse_time*1000;

subplot(3,3,1)
plot(time_p,force_i,'k');
hold on
plot(time_p,force_t,'m')
xlabel('Time (ms)')
ylabel('Force (kN)')
legend('Inc Bar','Trans Bar')
title('Force Balance')
hold off

subplot(3,3,2)
plot(time_p,(force_i - force_t),'k');
hold on
xlabel('Time (ms)')
ylabel('Force (kN)')
title('(Diff) Force Balance')

% Add in annotation on the foce difference plot with s
anno = sum(abs(force_i - force_t));
str = [char(8721) '|F| = ' num2str(anno) ' kN'];
ylim=get(gca,'ylim');
xlim=get(gca,'xlim');
xrange=xlim(2)-xlim(1);
yrange=ylim(2)-ylim(1);
xpos=xlim(1)+0.05*xrange;
ypos=ylim(1)+0.05*yrange;
text('Position',[xpos ypos],'String',str);
hold off

subplot(3,3,3)
plot(disp_1,force_t,'k');
hold on
plot(disp_3,force_3,'m')
ylabel('Force (kN)')
xlabel('Displacement (mm)')
legend('1-Wave','3-Wave')
title('Force-Displacement')
hold off

subplot(3,3,4)
plot(time_p, inc_wave(:,2),'Color',c1);
hold on
plot(time_p, -ref_wave(:,2),'Color',c2)
plot(time_p, tra_wave(:,2),'Color',c3)
xlabel('Time (ms)')
ylabel('Strain (mm/mm)')
legend('Inc','Refl (INV)','Trans')
title('All Waves Shifted')
hold off


subplot(3,3,5)
plot(time_p,vel_1,'k');
hold on
plot(time_p,vel_3,'m')
xlabel('Time (ms)')
ylabel('Velocity (m/s)')
legend('1-Wave','3-Wave')
title('Velocity')
hold off

subplot(3,3,6)
plot(time_p,disp_1,'k');
hold on
plot(time_p,disp_3,'m')
xlabel('Time (ms)')
ylabel('Displacement (mm)')
legend('1-Wave','3-Wave')
title('Displacement')
hold off

subplot(3,3,7)
plot(inc_wave(:,1)*1000, inc_wave(:,2),'Color',c1)
xlabel('Time (ms)')
ylabel('Strain (mm/mm)')
title('Incident Wave')

subplot(3,3,8)
plot(ref_wave(:,1)*1000, ref_wave(:,2),'Color',c2);
xlabel('Time (ms)')
ylabel('Strain (mm/mm)')
title('Reflected Wave')

subplot(3,3,9)
plot(tra_wave(:,1)*1000, tra_wave(:,2),'Color',c3);
xlabel('Time (ms)')
ylabel('Strain (mm/mm)')
title('Transmitted Wave')

function sdc = applyDispersionCorrection(s,dt,dia,d2e,c0,const,isIW)
% applyDispersionCorrection: Applies dispersion correction to SHPB strain signals
%
% Calling code is responsible for input validation
% Arguments: (input)
%     s     - Uncorrected strain signal (mm/mm)
%     dt    - Time step in seconds (s)
%     dia   - Bar diameter in milimeters (mm)
%     d2e   - Distance from strain gage to bar end in milimeters (mm)
%     c0    - Wave speed in milimeters per second (mm/s)
%     const - Dispersion constants, [1,6]
%     isIW  - Flag indicating if strain signal is the incident wave (true)
%             or either the transmited or reflected strain signal (false)
% Arguments: (ouput)
%     sdc   - Dispersion corrected strain signal (mm/mm)
%     wtbr  - For waitbar values
%
% Author: David Francis & Collin Pecora, RDRL-WMP-G

s       = s(:)';        % Force to row vector
old_len = length(s);
pad     = zeros(1,old_len); % add zero padding
s       = [pad s pad];  % add zero padding
N       = length(s);    % Length of signal
n       = 1:N;          % Vectorise N
Ti      = 1/(N*dt);     % Inverse Period
omega0  = 2*pi*Ti;      
kmax    = ceil(N*0.5);
k       = 1:kmax;       % Vectorised kmax
a       = dia*0.5;      % Bar radius
ck0     = 0.5*c0;% FZERO intial values

% Generating the ck/c0 -- a/gamma dispersion curve (solving for phi)
% Vectorised a*k*omega/(2*pi) 
akomega = (a*k*Ti);

% FZERO is computationaly expensive.  With the assumtion that ck for 
% frequencies beyond 1250/a are constant, limit loop to minidx and loop
% backwards, adjusting initial value parameter of FZERO
minidx = min([ceil(((1250/a)*1000)/Ti) length(akomega)]);

% Get end value, set initial search start point
lowck = fzero(getPhiFcn(c0,const,akomega(minidx)),ck0);

% inialize ck array with low ck values
ck = ones(1,kmax)*lowck;

% loop fzero sover backwards, updating ck value
for itr = minidx:-1:1
    ck(itr) = fzero(getPhiFcn(c0,const,akomega(itr)),ck0);
    ck0 = ck(itr);
end
  

% Limit values to c0
ck(ck > c0) = c0;

% Set phi by waveform type
if isIW
    phi = k .* omega0 .* (d2e./ck - d2e/c0);
else
    phi = k .* omega0 .* (-d2e./ck + d2e/c0);
end

% Forward Fourier Transform 
A = 2* Ti *sum(bsxfun(@times,s,cos(bsxfun(@times,k',repmat((omega0.*n.*dt),kmax,1)))*dt),2)';
B = 2* Ti *sum(bsxfun(@times,s,sin(bsxfun(@times,k',repmat((omega0.*n.*dt),kmax,1)))*dt),2)';

% Shifted & Inverse Fourier Transform
I1  = bsxfun(@minus,bsxfun(@times,n',repmat((omega0.*k.*dt),N,1)),phi);
sdc = Ti .* sum(s .* dt) + sum((bsxfun(@times,B,sin(I1)) + bsxfun(@times,A,cos(I1))),2);

sdc = sdc(old_len+1:end-old_len); % remove padding

% Nested function
function fcn = getPhiFcn(c0,const,akomega)
    fcn = @(ck) (ck/c0-(const(1)+(const(2)/(const(3)*(akomega/ck)^4+const(4)*(akomega/ck)^3+const(5)*(akomega/ck)^2+const(6)*(akomega/ck)^(1.5)+1))));    

% --- Executes on button press in radiobutton_invert_t.
function radiobutton_invert_t_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_invert_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_invert_t
value = get(hObject,'Value');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

dataset.invert_t = value;
dataset.null_T = -dataset.null_T;  % invert null average

handles.user_data.dataset(idx) = dataset;

% Update handles structure
guidata(hObject, handles);

wave_clipping_replot(hObject, eventdata, handles)

% --- Executes on button press in radiobutton_invert_i.
function radiobutton_invert_i_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_invert_i (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_invert_i
value = get(hObject,'Value');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

dataset.invert_i = value; 
dataset.null_I = -dataset.null_I; % invert null average

handles.user_data.dataset(idx) = dataset;

% Update handles structure
guidata(hObject, handles);

wave_clipping_replot(hObject, eventdata, handles)

% --- Executes on button press in checkbox_null_i.
function checkbox_null_i_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_null_i (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_null_i


% --------------------------------------------------------------------
function File_Callback(hObject, eventdata, handles)
% hObject    handle to File (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Write_Callback(hObject, eventdata, handles)
% hObject    handle to Write (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Test_Data_Callback(hObject, eventdata, handles)
% hObject    handle to Test_Data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_Bar_Callback(hObject, eventdata, handles)
% hObject    handle to Load_Bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Please pick restart file for previously created bar(s).'))
dialog_title = 'Bar restart file'; 

[file_name, file_path] = uigetfile({'*.mat', 'Bar Restart file'}, ...
    dialog_title, handles.user_data.last_dir_load);
target_filename = fullfile(file_path,file_name);

% get filenames
if file_path == 0, return, end

h = waitbar(0,['Loading bar restart file from ' file_name ' ...']);

load(target_filename); % should get structure: export_bar

if ~exist('export_bar','var')
    errordlg('Bar(s) not imported. Error with restart file', 'Error') 
    close(h)
    return
end

waitbar(0.5)

if isempty(handles.user_data.barsetup)
    handles.user_data.barsetup = export_bar;
else
    barsetup = handles.user_data.barsetup;
    
    names_new = {export_bar.tag};
    names_old = {barsetup.tag};
    
    % find index(s) for similar names in new string
    cmp = find(ismember(names_new,names_old));

    % need to modify names if shared
    if ~isempty(cmp)
        % combine the oldnames and identical new names to a new string
        name_cmb = [names_old names_new(cmp)];

        % modify the new names 
        name_cmb = matlab.lang.makeUniqueStrings(name_cmb);

        % stick the new unique names back into the new name array
        names_new(cmp) = name_cmb(end-length(cmp)+1:end);

        % replace tag(s) with new names
        for i = 1:length(names_new)
            export_bar(i).tag = names_new{i};
        end
    end
        
    % append structure with imported values
    barsetup(end+1:end+length(export_bar)) = export_bar;
    handles.user_data.barsetup = barsetup;
end


% update the list in the pop up menu for the bars
popdisp={'(select)',handles.user_data.barsetup.tag};
set(handles.popupmenu_i_bar,'String',popdisp);
set(handles.popupmenu_t_bar,'String',popdisp);

% Update handles
guidata(hObject, handles);
waitbar(1), close(h)


% --------------------------------------------------------------------
function v_group_Callback(hObject, eventdata, handles)
% hObject    handle to v_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function vug_group_Callback(hObject, eventdata, handles)
% hObject    handle to vug_group (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function test_binary_Callback(hObject, eventdata, handles)
% hObject    handle to test_binary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Using this import feature: Data file must be a restart file from a previous session.'))
dialog_title = 'Select Restart File'; 

[file_name, file_path] = uigetfile({'*.mat', 'Restart File (*.mat)'}, ...
    dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

% return if no file is chosen
if file_path == 0, return, end

h = waitbar(0,sprintf('Loading restart file from %s ...',file_name) );

load(target_filename)

if ~exist('export_raw','var')
    errordlg('Data not imported. Error with restart file', 'Error') 
    close(h)
    return
end

waitbar(0.5)

% in the case that no data for samples or bars currently exist
if isempty(handles.user_data.dataset) && isempty(handles.user_data.barsetup)
    handles.user_data.dataset = export_raw.dataset;
    handles.user_data.barsetup = export_raw.barsetup;
    
    % set the datasetp popup menu
    popdisp={'(select)',handles.user_data.dataset.tag};
    set(handles.popupmenu_dataset,'string',popdisp)
    
    % set the bar menu if needed
    if ~isempty(handles.user_data.barsetup)
        popdispb = {'(select)',handles.user_data.barsetup.tag};
        set(handles.popupmenu_i_bar,'string',popdispb)
        set(handles.popupmenu_t_bar,'string',popdispb)
    end

% in the case that no data for samples currently exist but bars do exist
elseif isempty(handles.user_data.dataset) && ~isempty(handles.user_data.barsetup)
    handles.user_data.dataset = export_raw.dataset;
        
    % set the datasetp popup menu
    popdisp={'(select)',handles.user_data.dataset.tag};
    set(handles.popupmenu_dataset,'string',popdisp)
    
    % set the bar menu if needed (assuming there was bar information in the
    % restart file)
    if ~isempty(export_raw.barsetup)
        
        % check to make sure names are not duplicated
        names_old = {handles.user_data.barsetup.tag};
        names_new = {export_raw.barsetup.tag};
        
        % find index(s) for similar names in new string
        cmp = find(ismember(names_new,names_old));
        
        % need to modify names if shared
        if ~isempty(cmp)
            % combine the oldnames and identical new names to a new string
            name_cmb = [names_old names_new(cmp)];

            % modify the new names 
            name_cmb = matlab.lang.makeUniqueStrings(name_cmb);

            % stick the new unique names back into the new name array
            names_new(cmp) = name_cmb(end-length(cmp)+1:end);
            
            % replace tag(s) with new names
            for i = 1:length(names_new)
                export_raw.barsetup(i).tag = names_new{i};
            end
        end
        
        % append new bars to old bars
        handles.user_data.barsetup(end+1:end+length(names_new)) = export_raw.barsetup;
        
        % update the bar menu
        popdispb = {'(select)',handles.user_data.barsetup.tag};
        set(handles.popupmenu_i_bar,'string',popdispb)
        set(handles.popupmenu_t_bar,'string',popdispb)
    end
    
% Case 3: data and bar data exists in GUI prior to importing
elseif ~isempty(handles.user_data.dataset) && ~isempty(handles.user_data.barsetup)
    % check to make sure names are not duplicated in sample set
    names_old = {handles.user_data.dataset.tag};
    names_new = {export_raw.dataset.tag};

    % find index(s) for similar names in new string
    cmp = find(ismember(names_new,names_old));

    % need to modify names if shared
    if ~isempty(cmp)
        % combine the oldnames and identical new names to a new string
        name_cmb = [names_old names_new(cmp)];

        % modify the new names 
        name_cmb = matlab.lang.makeUniqueStrings(name_cmb);

        % stick the new unique names back into the new name array
        names_new(cmp) = name_cmb(end-length(cmp)+1:end);

        % replace tag(s) with new names
        for i = 1:length(names_new)
            export_raw.dataset(i).tag = names_new{i};
        end
    end

    % append new data to current data
    handles.user_data.dataset(end+1:end+length(names_new)) = export_raw.dataset;
    
    % set the datasetp popup menu
    popdisp={'(select)',handles.user_data.dataset.tag};
    set(handles.popupmenu_dataset,'string',popdisp)
    
    % set the bar menu if needed (assuming there was bar information in the
    % restart file)
    if ~isempty(export_raw.barsetup)
        
        % check to make sure names are not duplicated
        names_old = {handles.user_data.barsetup.tag};
        names_new = {export_raw.barsetup.tag};
        
        % find index(s) for similar names in new string
        cmp = find(ismember(names_new,names_old));
        
        % need to modify names if shared
        if ~isempty(cmp)
            % combine the oldnames and identical new names to a new string
            name_cmb = [names_old names_new(cmp)];

            % modify the new names 
            name_cmb = matlab.lang.makeUniqueStrings(name_cmb);

            % stick the new unique names back into the new name array
            names_new(cmp) = name_cmb(end-length(cmp)+1:end);
            
            % replace tag(s) with new names
            for i = 1:length(names_new)
                export_raw.barsetup(i).tag = names_new{i};
            end
        end
        
        % append new bars to old bars
        handles.user_data.barsetup(end+1:end+length(names_new)) = export_raw.barsetup;
        
        % update the bar menu
        popdispb = {'(select)',handles.user_data.barsetup.tag};
        set(handles.popupmenu_i_bar,'string',popdispb)
        set(handles.popupmenu_t_bar,'string',popdispb)
    end
% Case 4: dataset exist and and bar data does not exists in GUI prior to importing
elseif ~isempty(handles.user_data.dataset) && isempty(handles.user_data.barsetup)
     % check to make sure names are not duplicated in sample set
    names_old = {handles.user_data.dataset.tag};
    names_new = {export_raw.dataset.tag};

    % find index(s) for similar names in new string
    cmp = find(ismember(names_new,names_old));

    % need to modify names if shared
    if ~isempty(cmp)
        % combine the oldnames and identical new names to a new string
        name_cmb = [names_old names_new(cmp)];

        % modify the new names 
        name_cmb = matlab.lang.makeUniqueStrings(name_cmb);

        % stick the new unique names back into the new name array
        names_new(cmp) = name_cmb(end-length(cmp)+1:end);

        % replace tag(s) with new names
        for i = 1:length(names_new)
            export_raw.dataset(i).tag = names_new{i};
        end
    end

    % append new data to current data
    handles.user_data.dataset(end+1:end+length(names_new)) = export_raw.dataset;
    
    % set the datasetp popup menu
    popdisp={'(select)',handles.user_data.dataset.tag};
    set(handles.popupmenu_dataset,'string',popdisp)
    
    % if bars were imported then...
    if ~isempty(export_raw.barsetup)
    	handles.user_data.barsetup = export_raw.barsetup;
        popdispb = {'(select)',handles.user_data.barsetup.tag};
        set(handles.popupmenu_i_bar,'string',popdispb)
        set(handles.popupmenu_t_bar,'string',popdispb) 
    end
end

guidata(hObject,handles)
waitbar(1), close(h)

% --------------------------------------------------------------------
function excel_vg_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function data_vg_Callback(hObject, eventdata, handles)
% hObject    handle to data_vg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Using this import feature: Data file can be comma or tab delimited. Must have 2 columns'))
dialog_title = 'Select Data File'; 

[file_name, file_path] = uigetfile({'*.csv', 'Comma Seperated (*.csv)'; ...
   '*.txt','Text (*.txt)'; '*.dat','Data (*.dat)'; '*.*','All Files';}, ...
    dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

% if the user cancels, then do nothing
if file_path == 0, return, end

h = waitbar(0,['Loading data from ' file_name ' ...']);

% call to import the data from the file
voltages = importdata(target_filename);
waitbar(0.5)

% Need to make sure only 2 columns are in the file
[~, n] = size(voltages);

if n == 2
    handles = dataimport(handles,voltages,target_filename,file_name,file_path);

    % Update handles structure
    guidata(hObject,handles); 
    waitbar(1)
elseif n > 2
    errordlg('Data not imported. Too many columns', 'Error') 
elseif n < 2
    errordlg('Data not imported. For single columns, use ungrouped data option', 'Error') 
end
close(h)

% --------------------------------------------------------------------
function excel_vg_int_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vg_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Using this import feature: When Excel Loads, highlight data in adjacent columns.'))
dialog_title = 'Select Excel File. When Excel Loads, highlight data in adjacent columns.'; % use tag w/o "_" as popup window title

[file_name, file_path] = uigetfile('*.xl*', dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

% if the user cancels, then do nothing
if file_path == 0, return, end

h = waitbar(0,['Loading data from ' file_name ' ...']);

% import call (this is usually time consuming)
voltages = xlsread(target_filename, -1);

% Need to make sure only 2 columns are in the file
[~, n] = size(voltages);
waitbar(0.5)

if n == 2
    handles = dataimport(handles,voltages,target_filename,file_name,file_path);

    % Update handles structure
    guidata(hObject,handles); 
    waitbar(1)
else
   errordlg('Data not imported. Please retry by highlight data in adjacent columns (left incident, right transmitted)', 'Error') 
end
close(h)

% --------------------------------------------------------------------
function excel_vg_auto_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vg_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Using this import feature, the Excel file must only contain 2 columns. The first column is incident bar voltage and second is transmitted bar voltage'))
dialog_title = 'Select Excel File';

[file_name, file_path] = uigetfile('*.xl*', dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

% if the user cancels, then do nothing
if file_path == 0, return, end

h = waitbar(0,['Loading data from ' file_name '...']);

% import call (this is usually time consuming)
voltages = xlsread(target_filename);
waitbar(0.5)

% Need to make sure only 2 columns are in the file
[~, n] = size(voltages);

if n == 2
    handles = dataimport(handles,voltages,target_filename,file_name,file_path);

    % Update handles structure
    guidata(hObject,handles); 
    waitbar(1)
else
    uiwait(msgbox('This Excel file has more/less than 2 columns of information. Please import data with Excel -> Interactive instead'))
end
close(h)

function handles = dataimport(handles,tval,target_filename,file_name,file_path)

dataset.target_filename = target_filename;  
dataset.material = ''; 
dataset.source = ''; 
dataset.notes = ''; 
dataset.time = []; % Array to be determined by sampling frequency & length of clipped wave
dataset.volt_raw_I = tval(:,1); % Raw voltages from incident bar strain gage
dataset.volt_raw_T = tval(:,2); % Raw voltages from transmitted bar strain gage
dataset.null_I = 0; % Value to null volt_raw_I
dataset.null_T = 0; % Value to null volt_raw_T
dataset.rough_crop_indicies = []; % 2 values to provide a rough crop for raw data
dataset.invert_i = 0; % 0/1 = not flipped/flipped
dataset.invert_t = 0; % 0/1 = not flipped/flipped
dataset.wave_length = []; % Length of the wave used for the analysis
dataset.inc_idx = []; % Index for start of incident wave
dataset.trans_idx = []; % Index for start of transmitted wave
dataset.refl_idx = []; % Index for start of reflected wave
dataset.strainrate = []; 
dataset.stressstate = []; % zero for compression, one for tension 
dataset.invert_i = 0; % zero for unaltered, one for invert 
dataset.invert_t = 0; % zero for unaltered, one for invert
dataset.plotvisability = 1; % 1 on, 0 off. For Plotting purposes
dataset.plotiso = 0; % 1 on, 0 off. Ablity to isolate plots
dataset.length = []; 
dataset.area = []; 
dataset.bar_i_idx = []; % index pointing to transmitted bar
dataset.bar_t_idx = []; % index pointing to incident bar
dataset.dispersion_pre = []; % index pointing for nu = 0.2 - 0.35
dataset.dispersion_man = []; % array for A-F

old_datasets = handles.user_data.dataset;

if isempty(old_datasets)
    dataset.tag = file_name;
    handles.user_data.dataset = dataset;
else    
    % Need unique tag names, so check current file names against new one
    idx = cellfun('isempty',strfind({old_datasets.tag},file_name)); 
    if all(idx == 1)
        dataset.tag = file_name; % Ok with new name
    else
        % make cell array of existing names with new name
        name_cmb = [{old_datasets.tag} file_name];
        
        % modify the new name 
        name_cmb = matlab.lang.makeUniqueStrings(name_cmb);
        
        % update the tag with the newly modifed name
        dataset.tag = name_cmb{end};
    end
    handles.user_data.dataset(end+1) = dataset;
end

popdisp={'(select)',handles.user_data.dataset.tag};
set(handles.popupmenu_dataset,'string',popdisp)

handles.user_data.last_dir_load = file_path;
    
% --------------------------------------------------------------------
function write_sample_Callback(hObject, eventdata, handles)
% hObject    handle to write_sample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Write_Bar_Callback(hObject, eventdata, handles)
% hObject    handle to Write_Bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isempty(handles.user_data.barsetup)
    errordlg('No bars created to write','Bar Write Error');
    return
end

% setup date string
formatOut = 'yyyy_mm_dd';
a = datestr(now,formatOut);

% generate default name
filename = [a '_bar_restart.mat'];

% save dialog box popup
[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

h = waitbar(0,['Saving ' file]);

export_bar = handles.user_data.barsetup;

waitbar(0.5)

save(filename,'export_bar')
waitbar(1), close(h)

% --------------------------------------------------------------------
function write_matlab_Callback(hObject, eventdata, handles)
% nothing happens in this menu callback

% --------------------------------------------------------------------
function write_excel_Callback(hObject, eventdata, handles)
% nothing happens in this menu callback


% --------------------------------------------------------------------
function write_restart_Callback(hObject, eventdata, handles)
% hObject    handle to write_restart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% see if any data has been imported
if isempty(handles.user_data.dataset)
    errordlg('No data available to write','Restart Write Error');
    return
end

% generate default name
a = datestr(now,'yyyy_mm_dd');
filename = [a '_restart' '.mat'];

[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

export_raw = handles.user_data;
export_raw = rmfield(export_raw,{'last_dir_load', 'last_dir_save'});

save(filename,'export_raw')


% --------------------------------------------------------------------
function write_excel_single_Callback(hObject, eventdata, handles)
% hObject    handle to write_excel_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Wave Clipping Error','modal'));clc
    return
end

% index
idx = focus - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);
barsetup = handles.user_data.barsetup;

% Call function to find potential errors
export_error_msg = export_error(dataset,barsetup);

if ~isempty(export_error_msg)
    uiwait(errordlg(export_error_msg,'Error','modal'));
    return
end

% get default file name
filename = [matlab.lang.makeValidName(dataset.tag) '.xlsx'];

[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

h = waitbar(0,['Exporting to ' file '. Box will close when complete.']);

% Call function to get 'Plotted' Values
export_data = exp_data(dataset,barsetup,2);
waitbar(.3)
% Header information
header_export = {'Tag',dataset.tag;'Filename',dataset.target_filename; 'Export Date', datestr(datetime('now'))};
         
if ~isempty(dataset.material)
	header_export = [header_export; {'Material', dataset.material}];
end
if ~isempty(dataset.notes)
	header_export = [header_export; {'Notes', dataset.notes}];
end
if ~isempty(dataset.source)
	header_export = [header_export; {'Source', dataset.source}];
end
if ~isempty(dataset(i).strainrate)
    header_export = [header_export; {'Source', dataset(i).strainrate}];
end

% Create Axis Titles
AxisTitle = {'Time (s)' 'Eng Strain: 1 Wave (mm/mm)' 'Eng Strain: 3 Wave (mm/mm)' ...
    'True Strain: 1 Wave (mm/mm)' 'True Strain: 3 Wave (mm/mm)' 'Eng Stress: 1 Wave (Pa)' 'Eng Stress: 3 Wave (Pa)' ...
    'True Stress: 1 Wave (Pa)' 'True Stress: 3 Wave (Pa)' 'Eng Strain Rate: 1 Wave (1/s)' 'Eng Strain Rate: 3 Wave (1/s)' ...
    'True Strain Rate: 1 Wave (1/s)' 'True Strain Rate: 3 Wave (1/s)' 'Displacement: 1 Wave (m)' 'Displacement: 3 Wave (m)' ...
    'Force: Transmitted Bar (N)' 'Force: Incident Bar (N)' 'Force: Average (N)' ...
    'Velocity: 1 Wave (m/s)' 'Velocity: 3 Wave (m/s)' 'Incident Wave Strain (mm/mm)' ...
    'Reflected Wave Strain (mm/mm)' 'Transmitted Wave Strain (mm/mm)'};

% How many rows to drop down...
rsk = size(header_export);

xr1 = 'A1';
xr2 = ['A' num2str(rsk(1)+2)];
xr3 = ['A' num2str(rsk(1)+3)];

% setup arguements for following xlswrite commands
sheet = matlab.lang.makeValidName(dataset.tag);

% suppress defualt warning from xlswrite when creating a new sheet
warning('off','MATLAB:xlswrite:AddSheet');

waitbar(.4)
xlswrite(filename,header_export,sheet,xr1)
waitbar(.6)
xlswrite(filename,AxisTitle,sheet,xr2)
waitbar(.8)
xlswrite(filename,export_data,sheet,xr3)

% Delete sheet1 from workbook
newExcel = actxserver('excel.application');
excelWB = newExcel.Workbooks.Open(filename,0,false);
newExcel.DisplayAlerts = false;
excelWB.Sheets.Item(1).Delete;
excelWB.Save();
excelWB.Close();
newExcel.Quit();
delete(newExcel);

waitbar(1)
close(h)

% --------------------------------------------------------------------
function write_excel_all_Callback(hObject, eventdata, handles)
% hObject    handle to write_excel_single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% load data and shorted addresses
dataset = handles.user_data.dataset;
barsetup = handles.user_data.barsetup;

% setup index that points to completed datasets and non-completed datasets
idx_export = [];
no_name = {};

% create pointer for completed data, and list of names of incompleted' data
for i=1:length(dataset)
    export_error_msg = export_error(dataset(i),barsetup);
    if isempty(export_error_msg)
        idx_export = [idx_export i];
    else
        no_name = [no_name, {dataset(i).tag}];
    end
end

% in case no datasets are ready to be exported
if isempty(idx_export)
    uiwait(errordlg('No datasets have been properly completed','Error','modal'));
    return
end

% get default file name
a = datestr(now,'yyyy_mm_dd');
filename = [a '_SHPB_GUI_Anlaysis_Data_Export' '.xlsx'];

% pop up box for users to pick save location
[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

% Display which datasets were not considered for exporting
if ~isempty(no_name)
    uiwait(errordlg(['The following datasets were not exported as they have uncompleted steps: ' strjoin(no_name,', ')],'Error','modal'));
end

wb = waitbar(0,'Exporting excel file...');

% Column title cell array
AxisTitle = {'Time (s)' 'Eng Strain: 1 Wave (mm/mm)' 'Eng Strain: 3 Wave (mm/mm)' ...
    'True Strain: 1 Wave (mm/mm)' 'True Strain: 3 Wave (mm/mm)' 'Eng Stress: 1 Wave (Pa)' 'Eng Stress: 3 Wave (Pa)' ...
    'True Stress: 1 Wave (Pa)' 'True Stress: 3 Wave (Pa)' 'Eng Strain Rate: 1 Wave (1/s)' 'Eng Strain Rate: 3 Wave (1/s)' ...
    'True Strain Rate: 1 Wave (1/s)' 'True Strain Rate: 3 Wave (1/s)' 'Displacement: 1 Wave (m)' 'Displacement: 3 Wave (m)' ...
    'Force: Transmitted Bar (N)' 'Force: Incident Bar (N)' 'Force: Average (N)' ...
    'Velocity: 1 Wave (m/s)' 'Velocity: 3 Wave (m/s)' 'Incident Wave Strain (mm/mm)' ...
    'Reflected Wave Strain (mm/mm)' 'Transmitted Wave Strain (mm/mm)'};

% setup valid and unique field names
fnames = matlab.lang.makeValidName({dataset(idx_export).tag});
fnames = matlab.lang.makeUniqueStrings(fnames);
j=1;
numsheet = length(idx_export);

%suppress default warning from xlswrite when creating a new sheet
warning('off','MATLAB:xlswrite:AddSheet');

for i = idx_export
    % Call function to get 'Plotted' Values
    export_data = exp_data(dataset(i),barsetup,2);
    
    % Header information
    header_export = {'Tag',dataset(i).tag;'Filename',dataset(i).target_filename; 'Export Date', datestr(datetime('now'))};

    if ~isempty(dataset(i).material)
        header_export = [header_export; {'Material', dataset(i).material}];
    end
    if ~isempty(dataset(i).notes)
        header_export = [header_export; {'Notes', dataset(i).notes}];
    end
    if ~isempty(dataset(i).source)
        header_export = [header_export; {'Source', dataset(i).source}];
    end
    if ~isempty(dataset(i).strainrate)
        header_export = [header_export; {'Source', dataset(i).strainrate}];
    end

    % How many rows to drop down...
    rsk = size(header_export);

    xr1 = 'A1';
    xr2 = ['A' num2str(rsk(1)+2)];
    xr3 = ['A' num2str(rsk(1)+3)];
   
    sheet = fnames{j};
    
    xlswrite(filename,header_export,sheet,xr1)
    waitbar((3*j-2)/(numsheet*3))
    xlswrite(filename,AxisTitle,sheet,xr2)
    waitbar((3*j-1)/(numsheet*3))
    xlswrite(filename,export_data,sheet,xr3)
    waitbar((3*j)/(numsheet*3))
    j = j+1;
end

% Delete sheet1 from workbook
newExcel = actxserver('excel.application');
excelWB = newExcel.Workbooks.Open([filename],0,false);
newExcel.DisplayAlerts = false;
excelWB.Sheets.Item(1).Delete;
excelWB.Save();
excelWB.Close();
newExcel.Quit();
delete(newExcel);
close(wb)


% --------------------------------------------------------------------
function write_matlab_all_Callback(hObject, eventdata, handles)
% hObject    handle to write_matlab_all (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% load data and shorted addresses
dataset = handles.user_data.dataset;
barsetup = handles.user_data.barsetup;

% setup index that points to completed datasets and non-completed datasets
idx_export = [];
no_name = {};

for i=1:length(dataset)
    export_error_msg = export_error(dataset(i),barsetup);
    if isempty(export_error_msg)
        idx_export = [idx_export i];
    else
        no_name = [no_name, {dataset(i).tag}];
    end
end


if isempty(idx_export)
    uiwait(errordlg('No datasets have been properly completed','Error','modal'));
    close(h)
    return
end

% Display which datasets were not considered for exporting
if ~isempty(no_name)
    uiwait(errordlg(['The following datasets were not exported as they have uncompleted steps: ' strjoin(no_name,', ')],'Error','modal'));
end

% create default file name
formatOut = 'yyyy_mm_dd';
a = datestr(now,formatOut);
filename = [a '_SHPB_GUI_Anlaysis_Data_Export' '.mat'];

% pop up box for users to pick save location
[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

wb = waitbar(0,'Exporting .mat file...');

% setup temporary structure
s = struct;

% setup valid and unique field names
fnames = matlab.lang.makeValidName({dataset(idx_export).tag});
fnames = matlab.lang.makeUniqueStrings(fnames);
j=1;

for i = idx_export
    waitbar(0.8*j/length(idx_export))
    % Call function to get 'Plotted' Values
    export_data = exp_data(dataset(i),barsetup,1);
    s.(fnames{j})= export_data;
    j = j+1;
end

export_data = s;

waitbar(.9)
save(filename,'export_data')
waitbar(1)
close(wb)


% --------------------------------------------------------------------
function write_matlab_single_Callback(hObject, eventdata, handles)
% hObject    handle to write_matlab_single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Wave Clipping Error','modal'));
    return
end

% index
idx = focus - 1;

% load data and shorted addresses
dataset = handles.user_data.dataset(idx);
barsetup = handles.user_data.barsetup;

% Call fuction to find potential errors
export_error_msg = export_error(dataset,barsetup);

if ~isempty(export_error_msg)
    uiwait(errordlg(export_error_msg,'Error','modal'));
    return
end

% create default file name
formatOut = 'yyyy_mm_dd';
a = datestr(now,formatOut);
filename = [dataset.tag '.mat'];

% pop up box for users to pick save location
[file,path] = uiputfile(filename,'Save file name');
filename = fullfile(path,file);

if path == 0, return, end

wb = waitbar(0,'Exporting .mat file...');

% Call function to get 'Plotted' Values
export_data = exp_data(dataset,barsetup,1);

waitbar(0.5)

save(filename,'export_data')
waitbar(1)
close(wb)


function export_data = exp_data(dataset,barsetup,flag)
% arguements:
% - dataset: structure of the voltages and modifying data
% - barsetup: structure containing details of the bar setup
% - flag: switch that returns a structure (1) or combined matrix (2)

% Setup bar structures
barsetup_i = barsetup(dataset.bar_i_idx);
barsetup_t = barsetup(dataset.bar_t_idx);

% function to determine whether or not to invert the signal
fact_i = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
fact_t = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% nulled values
null_i = dataset.null_I;
null_t = dataset.null_T;

% Index start/end
idxst = [dataset.inc_idx dataset.refl_idx dataset.trans_idx];
pulse_width = dataset.wave_length;
idxend = idxst + pulse_width;
    
% cropped voltages
volt_i = dataset.volt_raw_I(idxst(1):idxend(1));
volt_r = dataset.volt_raw_I(idxst(2):idxend(2));
volt_t = dataset.volt_raw_T(idxst(3):idxend(3));

% Gage Factors
gf_i = barsetup_i.gagefactor;
gf_t = barsetup_t.gagefactor;

% Cropped, (inverted), and nulled, strains
strain_i = (volt_i - null_i) * fact_i * gf_i;
strain_r = (volt_r - null_i) * fact_i * gf_i;
strain_t = (volt_t - null_t) * fact_t * gf_t;

% Bar Properties (mm^2)
area_i = (barsetup_i.diameter)^2 * 0.25 * pi;
area_t = (barsetup_t.diameter)^2 * 0.25 * pi;

% Moduli (MPa) or (10^6 * kg/ms^2)
mod_i  = barsetup_i.modulus;
mod_t  = barsetup_t.modulus;

% Wave speeds (m/s)
wspeed_i = barsetup_i.wavespeed;
wspeed_t = barsetup_t.wavespeed;

% create time array
freq = barsetup_i.samplefreq;
dt = 1/(freq*10^6);
time = (0:pulse_width)'*dt;

%run dispersion if activated:
if any(dataset.dispersion_pre) || any(dataset.dispersion_man)

    if dataset.dispersion_pre ~=0
        const = [0.5875 , 0.41473, 41.305, 12.208, -9.4836, 3.0893; ...
                 0.58626, 0.41589, 38.715, 13.257, -9.3202, 3.0344; ...
                 0.58499, 0.41708, 36.051, 14.339, -9.1552, 2.9774; ...
                 0.58367, 0.41832, 33.312, 15.458, -8.9934, 2.9202; ...
                 0.58232, 0.41958, 30.564, 16.551, -8.8078, 2.8552; ...
                 0.58092, 0.42088, 27.792, 17.636, -8.6088, 2.7857; ...
                 0.57972, 0.42201, 26.257, 18.005, -8.2969, 2.7116; ...
                 0.5785,  0.42315, 24.674, 18.385, -7.9743, 2.6328; ...
                 0.57724, 0.42434, 23.039, 18.79,  -7.6529, 2.5538; ...
                 0.57594, 0.42555, 21.326, 19.224, -7.3258, 2.4713; ...
                 0.5746,  0.42681, 19.53,  19.702, -7.0054, 2.3897; ...
                 0.57344, 0.4279,  18.668, 19.664, -6.6213, 2.3118; ...
                 0.57228, 0.42901, 17.781, 19.636, -6.2337, 2.2327; ...
                 0.57106, 0.43016, 16.764, 19.679, -5.8543, 2.1532; ...
                 0.56983, 0.43132, 15.741, 19.714, -5.4671, 2.0717; ...
                 0.56855, 0.43254, 14.602, 19.809, -5.0851, 1.9895];
        c_val = const(dataset.dispersion_pre,:); 
    else
        c_val = dataset.dispersion_man;
    end 
    a_i = barsetup_i.diameter / 1000; % (in meters)
    a_t = barsetup_t.diameter / 1000; % (in meters)
    dist_i = dt * 0.5 * wspeed_i * (idx_st(2) - idx_st(1)); % (in meters)
    dist_t = dt * (idx_st(3)*wspeed_t - idx_st(1)*wspeed_i) - dist_i; % (in meters)

    strain_i = applyDispersionCorrection(strain_i,dt,a_i,dist_i,wspeed_i,c_val,1);
    strain_r = applyDispersionCorrection(strain_r,dt,a_i,dist_i,wspeed_i,c_val,0);
    strain_t = applyDispersionCorrection(strain_t,dt,a_t,dist_t,wspeed_t,c_val,0);
end

% Force calculation (N)
force_i = area_i * mod_i * (strain_i + strain_r);
force_t = area_t * mod_t * strain_t;
force_3 = (force_i+force_t)/2;

% Velocity calculations (m/s)
vel_3 = wspeed_i*(strain_i - strain_r) - wspeed_t*strain_t;
vel_1 = -2*wspeed_i*strain_r;

% Displacement calculations (m)
disp_3 = cumtrapz(vel_3)*dt;
disp_1 = cumtrapz(vel_1)*dt;

% Specimen Engineering Strain (mm/mm)
s_length = dataset.length/1000; % convert mm to m
eng_strain3 = disp_3/s_length;
eng_strain1 = disp_1/s_length;

% Specimen True Strain (mm/mm)
true_strain3 = log(1+eng_strain3);
true_strain1 = log(1+eng_strain1);

% Specimen Strain Rate (1/s)
eng_strain3_rate  = diff(eng_strain3)/dt;
eng_strain1_rate  = diff(eng_strain1)/dt;
true_strain3_rate = diff(true_strain3)/dt;
true_strain1_rate = diff(true_strain1)/dt;

% Add another value at the end to make array length same
eng_strain3_rate(end+1)  = eng_strain3_rate(end);
eng_strain1_rate(end+1)  = eng_strain1_rate(end);
true_strain3_rate(end+1) = true_strain3_rate(end);
true_strain1_rate(end+1) = true_strain1_rate(end);

% Engineering Stress (Pa)
s_area = dataset.area*10^-6; 
eng_stress3 = force_i/s_area;
eng_stress1 = force_t/s_area;

% True Stress
true_stress3 = eng_stress3.*(1+eng_strain3);
true_stress1 = eng_stress1.*(1+eng_strain1);

if flag == 1
    export_data = struct('time',time,'eng_strain1',eng_strain1,'eng_strain3',eng_strain3, ...
        'true_strain1',true_strain1,'true_strain3',true_strain3,'eng_stress1',eng_stress1, ...
        'eng_stress3',eng_stress3,'true_stress1',true_stress1,'true_stress3',true_stress3, ...
        'eng_strain1_rate',eng_strain1_rate,'eng_strain3_rate',eng_strain3_rate, ...
        'true_strain1_rate',true_strain1_rate,'true_strain3_rate',true_strain3_rate,...
        'disp_1',disp_1,'disp_3',disp_3,'force_t',force_t,'force_i',force_i,...
        'force_3',force_3,'vel_1',vel_1,'vel_3',vel_3, ...
         'strain_i',strain_i,'strain_r',strain_r,'strain_t',strain_t,...
         'tag',dataset.tag,'filename',dataset.target_filename,...
         'Raw_Incident_Voltage',dataset.volt_raw_I,'Raw_Transmitted_Voltage',dataset.volt_raw_T,...
         'Export_Date',datestr(datetime('now')));
     if ~isempty(dataset.material)
         export_data.material = dataset.material;
     end
     if ~isempty(dataset.notes)
         export_data.notes = dataset.notes;
     end
     if ~isempty(dataset.source)
         export_data.source = dataset.source;
     end
     if ~isempty(dataset.strainrate)
         export_data.strainrate = dataset.strainrate;
     end
elseif flag == 2
    export_data = [time, eng_strain1, eng_strain3, true_strain1, true_strain3, ...
        eng_stress1, eng_stress3, true_stress1, true_stress3, ...
        eng_strain1_rate, eng_strain3_rate, true_strain1_rate, true_strain3_rate, ...
        disp_1, disp_3, force_t, force_i, force_3, vel_1, vel_3, strain_i, strain_r, strain_t];
end
    
function export_error_msg = export_error(dataset,barsetup)
% function to return potential error msg
export_error_msg = {};

% force users to null data prior to clipping 
if dataset.null_I == 0 || dataset.null_T == 0
    export_error_msg = 'Please complete signal nulling step and try again.';
    return
end

% force users to crop data prior to clipping 
if isempty(dataset.rough_crop_indicies)
     export_error_msg = 'Please complete rough crop step and try again.';
    return
end

% check to see if users have applied a bar(s) to a dataset
if isempty(dataset.bar_i_idx) || isempty(dataset.bar_t_idx) || dataset.bar_t_idx==0 || dataset.bar_i_idx==0
    export_error_msg = 'Please select incident & transmitted bars prior to wave clipping.';
    return
end

% Need to have same sampling rate for each gage
if barsetup(dataset.bar_i_idx).samplefreq ~= barsetup(dataset.bar_t_idx).samplefreq
     export_error_msg = 'Incident and Transmitted bars have different sampling rates.';
    return
end

if isempty(dataset.inc_idx)
    export_error_msg = 'Please complete Wave Clipping.';
    return
end

if  isempty(dataset.length) || isempty(dataset.area)
    export_error_msg = 'Please include sample dimensions.';
    return
end


% --------------------------------------------------------------------
function excel_vug_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function data_vug_Callback(hObject, eventdata, handles)
% hObject    handle to data_vug (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('Using this import feature: Data file can be comma or tab delimited. Only 1 column/row'))
dialog_title = 'Select Data File (INCIDENT WAVE)'; 

[file_name, file_path] = uigetfile({'*.csv', 'Comma Seperated (*.csv)'; ...
   '*.txt','Text (*.txt)'; '*.dat','Data (*.dat)'; '*.*','All Files';}, ...
    dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

% get filenames
if file_path == 0
    return
end

h = waitbar(0,['Loading incident data from ' file_name ' ...']);

i_wave = importdata(target_filename);
waitbar(0.5)


if ~(prod(size(i_wave) - 1)) % a check to make sure only 1 column of data
    close(h)
    % Import Tranmitted data
    dialog_title = 'Select Data File (TRANSMITTED WAVE)'; 

    [file_name, file_path] = uigetfile({'*.csv', 'Comma Seperated (*.csv)'; ...
   '*.txt','Text (*.txt)'; '*.dat','Data (*.dat)'; '*.*','All Files';}, ...
    dialog_title, file_path);

    target_filename        = fullfile(file_path,file_name);
       
    if file_path == 0, return, end
  
    h = waitbar(0,['Loading transmitted data from ' file_name ' ...']);
    
    t_wave = importdata(target_filename);
    waitbar(0.5)
    
    if (prod(size(t_wave) - 1)) % check to see if more than 2 column
       errordlg('Data not imported. Too many columns', 'Error') 
       close(h)
       return
    end
    
    if length(i_wave) > length(t_wave)
        uiwait(msgbox('Incident signal trimmed to match length of transmitted signal'));
        i_wave(length(t_wave)+1:end) = [];
    end

    if length(t_wave) > length(i_wave)
    	uiwait(msgbox('Transmitted signal trimmed to match length of incident signal'));
    	t_wave(length(i_wave)+1:end) = [];
    end
    
    cmb_wave = [i_wave t_wave];
    handles = dataimport(handles,cmb_wave,target_filename,file_name,file_path);
    
    % Update handles structure
    guidata(hObject,handles); 
else
    errordlg('Data not imported. Too many columns', 'Error') 
end
close(h)



% --------------------------------------------------------------------
function excel_vug_int_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vug_int (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiwait(msgbox('Using this import feature: When Excel loads, highlight the incident signal.'))

dialog_title           = 'Select Excel File. Incident signal.';
[file_name, file_path] = uigetfile('*.xl*', dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

if file_path == 0, return, end

i_wave = xlsread(target_filename, -1);

if prod(size(i_wave) - 1) ~=0 % a check to make sure only 1 column of data
    errordlg('Data not imported. Please highlight only incident wave', 'Error') 
    return
end
    
uiwait(msgbox('When Excel loads, highlight the transmitted signal.'))

dialog_title           = 'Select Excel File. Transmitted signal.'; 
[file_name, file_path] = uigetfile('*.xl*', dialog_title, file_path);
target_filename        = fullfile(file_path,file_name);

if file_path == 0, return, end

t_wave = xlsread(target_filename, -1);

if prod(size(t_wave) - 1) ~= 0 % a check to make sure only 1 column of data
    errordlg('Data not imported. Please highlight only transmitted wave', 'Error') 
    return
end

if length(i_wave) > length(t_wave)
    uiwait(msgbox('Incident signal trimmed to match length of transmitted signal'));
    i_wave(length(t_wave)+1:end) = [];
end

if length(t_wave) > length(i_wave)
    uiwait(msgbox('Transmitted signal trimmed to match length of incident signal'));
    t_wave(length(i_wave)+1:end) = [];
end

handles = dataimport(handles,[i_wave t_wave],target_filename,file_name,file_path);

% Update handles structure
guidata(hObject,handles); 


% --------------------------------------------------------------------
function excel_vug_auto_Callback(hObject, eventdata, handles)
% hObject    handle to excel_vug_auto (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
uiwait(msgbox('About this import method: You will pick two Excel files corresponding to each signal. Each excel file must contain only 1 column of data.'))

dialog_title           = 'Select Excel File. Incident signal.';
[file_name, file_path] = uigetfile('*.xl*', dialog_title, handles.user_data.last_dir_load);
target_filename        = fullfile(file_path,file_name);

if file_path == 0, return, end

h = waitbar(0,[ 'Importing Excel data (incident) from ' file_name ' ...']);

[i_wave,~,~] = xlsread(target_filename);
waitbar(1), close(h)

if prod(size(i_wave) - 1) ~=0 % a check to make sure only 1 column of data
    errordlg('Data not imported. Make sure excel file only contains 1 column of data', 'Error') 
    return
end
    
uiwait(msgbox('When Excel loads, highlight the transmitted signal.'))

dialog_title           = 'Select Excel File. Transmitted signal.'; 
[file_name, file_path] = uigetfile('*.xl*', dialog_title, file_path);
target_filename        = fullfile(file_path,file_name);

if file_path == 0, return, end

h = waitbar(0,['Importing Excel data (transmitted) from ' file_name ' ... ']);

[t_wave,~,~] = xlsread(target_filename);
waitbar(0.5)

if prod(size(t_wave) - 1) ~= 0 % a check to make sure only 1 column of data
    errordlg('Data not imported. Make sure excel file only contains 1 column of data', 'Error') 
    close(h)
    return
end

if length(i_wave) > length(t_wave)
    uiwait(msgbox('Incident signal trimmed to match length of transmitted signal'));
    i_wave(length(t_wave):end) = [];
end

if length(t_wave) > length(i_wave)
    uiwait(msgbox('Transmitted signal trimmed to match length of incident signal'));
    t_wave(length(i_wave):end) = [];
end

handles = dataimport(handles,[i_wave t_wave],target_filename,file_name,file_path);

% Update handles structure
guidata(hObject,handles); 
waitbar(1), close(h)

% --- Executes on button press in checkbox_null_t.
function checkbox_null_t_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_null_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_null_t


function edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_tag as text
%        str2double(get(hObject,'String')) returns contents of edit_tag as a double

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

string_input = get(hObject,'String');
datasetnames = get(handles.popupmenu_dataset,'String'); 

if (any(strcmp(string_input,datasetnames))) || (any(string_input) == 0) % Checking to make sure user hasn't duplicated names or blank fields
    uiwait(errordlg('Please create a unique tag for each dataset','Unique Tag Needed','modal'));
    set(hObject,'String',datasetnames{focus});
else
    dataset.tag = string_input;
    datasetnames{focus} = string_input;
    set(handles.popupmenu_dataset,'String',datasetnames);
    handles.user_data.dataset(idx) = dataset;
end

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_matl_Callback(hObject, eventdata, handles)
% hObject    handle to edit_matl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_matl as text
%        str2double(get(hObject,'String')) returns contents of edit_matl as a double

user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    user_data.dataset(idx).material = string_input;
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_matl_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_matl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_source_Callback(hObject, eventdata, handles)
% hObject    handle to edit_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_source as text
%        str2double(get(hObject,'String')) returns contents of edit_source as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    user_data.dataset(idx).source = string_input;
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_notes_Callback(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_notes as text
%        str2double(get(hObject,'String')) returns contents of edit_notes as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    user_data.dataset(idx).notes = string_input;
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_notes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_notes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_strainrate.
function pushbutton_strainrate_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_strainrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    uiwait(errordlg('Please select a dataset and try again.','Wave Clipping Error','modal'));
    return
end

clearplots(hObject,1,1)

% index
idx = focus - 1;

dataset = handles.user_data.dataset(idx);
barsetup = handles.user_data.barsetup;

% Call function to find potential errors
export_error_msg = export_error(dataset,barsetup);

if ~isempty(export_error_msg)
    uiwait(errordlg(export_error_msg,'Error','modal'));
    return
end

barsetup_i = barsetup(dataset.bar_i_idx);
barsetup_t = barsetup(dataset.bar_t_idx);

% function to determine whether or not to invert the signal
fact_i = dataset.invert_i*(-2)+1; % 0/1 = not flipped/flipped
fact_t = dataset.invert_t*(-2)+1; % 0/1 = not flipped/flipped

% nulled values
null_i = dataset.null_I;
null_t = dataset.null_T;

% Index start/end
idxst = [dataset.inc_idx dataset.refl_idx dataset.trans_idx];
pulse_width = dataset.wave_length;
idxend = idxst + pulse_width;
    
% cropped voltages
volt_i = dataset.volt_raw_I(idxst(1):idxend(1));
volt_r = dataset.volt_raw_I(idxst(2):idxend(2));
volt_t = dataset.volt_raw_T(idxst(3):idxend(3));

% Gage Factors
gf_i = barsetup_i.gagefactor;
gf_t = barsetup_t.gagefactor;

% Cropped, (inverted), and nulled, strains
strain_i = (volt_i - null_i) * fact_i * gf_i;
strain_r = (volt_r - null_i) * fact_i * gf_i;
strain_t = (volt_t - null_t) * fact_t * gf_t;

% Moduli (MPa) or (10^6 * kg/ms^2)
mod_i  = barsetup_i.modulus;
mod_t  = barsetup_t.modulus;

% Wave speeds (m/s)
wspeed_i = barsetup_i.wavespeed;
wspeed_t = barsetup_t.wavespeed;

% create time array
freq = barsetup_i.samplefreq;
dt = 1/(freq*10^6);
time = (0:pulse_width)'*dt;

%run dispersion if activated:
if any(dataset.dispersion_pre) || any(dataset.dispersion_man)

    if dataset.dispersion_pre ~=0
        const = [0.5875 , 0.41473, 41.305, 12.208, -9.4836, 3.0893; ...
                 0.58626, 0.41589, 38.715, 13.257, -9.3202, 3.0344; ...
                 0.58499, 0.41708, 36.051, 14.339, -9.1552, 2.9774; ...
                 0.58367, 0.41832, 33.312, 15.458, -8.9934, 2.9202; ...
                 0.58232, 0.41958, 30.564, 16.551, -8.8078, 2.8552; ...
                 0.58092, 0.42088, 27.792, 17.636, -8.6088, 2.7857; ...
                 0.57972, 0.42201, 26.257, 18.005, -8.2969, 2.7116; ...
                 0.5785,  0.42315, 24.674, 18.385, -7.9743, 2.6328; ...
                 0.57724, 0.42434, 23.039, 18.79,  -7.6529, 2.5538; ...
                 0.57594, 0.42555, 21.326, 19.224, -7.3258, 2.4713; ...
                 0.5746,  0.42681, 19.53,  19.702, -7.0054, 2.3897; ...
                 0.57344, 0.4279,  18.668, 19.664, -6.6213, 2.3118; ...
                 0.57228, 0.42901, 17.781, 19.636, -6.2337, 2.2327; ...
                 0.57106, 0.43016, 16.764, 19.679, -5.8543, 2.1532; ...
                 0.56983, 0.43132, 15.741, 19.714, -5.4671, 2.0717; ...
                 0.56855, 0.43254, 14.602, 19.809, -5.0851, 1.9895];
        c_val = const(dataset.dispersion_pre,:); 
    else
        c_val = dataset.dispersion_man;
    end 
    a_i = barsetup_i.diameter / 1000; % (in meters)
    a_t = barsetup_t.diameter / 1000; % (in meters)
    dist_i = dt * 0.5 * wspeed_i * (idx_st(2) - idx_st(1)); % (in meters)
    dist_t = dt * (idx_st(3)*wspeed_t - idx_st(1)*wspeed_i) - dist_i; % (in meters)

    strain_i = applyDispersionCorrection(strain_i,dt,a_i,dist_i,wspeed_i,c_val,1);
    strain_r = applyDispersionCorrection(strain_r,dt,a_i,dist_i,wspeed_i,c_val,0);
    strain_t = applyDispersionCorrection(strain_t,dt,a_t,dist_t,wspeed_t,c_val,0);
end

% Velocity calculations (m/s)
vel_3 = wspeed_i*(strain_i - strain_r) - wspeed_t*strain_t;
vel_1 = -2*wspeed_i*strain_r;

% Displacement calculations (m)
disp_3 = cumtrapz(vel_3)*dt;
disp_1 = cumtrapz(vel_1)*dt;

% Specimen Engineering Strain (mm/mm)
s_length = dataset.length/1000; % convert mm to m
eng_strain3 = disp_3/s_length;
eng_strain1 = disp_1/s_length;

% Specimen True Strain (mm/mm)
true_strain3 = log(1+eng_strain3);
true_strain1 = log(1+eng_strain1);

% Specimen Strain Rate (1/s)
eng_strain3_rate  = diff(eng_strain3)/dt;
eng_strain1_rate  = diff(eng_strain1)/dt;
true_strain3_rate = diff(true_strain3)/dt;
true_strain1_rate = diff(true_strain1)/dt;

% Add another value at the end to make array length same
eng_strain3_rate(end+1)  = eng_strain3_rate(end);
eng_strain1_rate(end+1)  = eng_strain1_rate(end);
true_strain3_rate(end+1) = true_strain3_rate(end);
true_strain1_rate(end+1) = true_strain1_rate(end);


ts = [time(1) time(end)];
TS1A = repmat(mean(true_strain1_rate),1,2);
TS3A = repmat(mean(true_strain3_rate),1,2);
ES1A = repmat(mean(eng_strain1_rate),1,2);
ES3A = repmat(mean(eng_strain3_rate),1,2);

rates = [eng_strain1_rate eng_strain3_rate true_strain1_rate true_strain3_rate];
legendrate = {[char(941) '_{E1}'], [char(941) '_{E3}'] , [char(941) '_{T1}'], [char(941) '_{T3}']};

strains = [eng_strain1 eng_strain3 true_strain1 true_strain3];
legendstrain = {[char(949) '_{E1}'], [char(949) '_{E3}'] , [char(949) '_{T1}'], [char(949) '_{T3}']};

maxrate = max(max(rates));
minrate = min(min(rates));

if maxrate > abs(minrate)
    limr = [0 maxrate];
else
    limr = [minrate 0];
end

maxstrain = max(max(strains));
minstrain = min(min(strains));

if maxstrain > abs(minstrain)
    lims = [0 maxstrain];
else
    lims = [minstrain 0];
end

tp = time*1000;
tps = ts*1000;

axes('Parent', handles.Plot_panel)


for i = 1:4
    subplot(2,4,i)
    plot(tp,rates(:,i))
    hold on
    meanpts = repmat(mean(rates(:,i)),1,2);
    plot(tps,meanpts,'--k')
    xlabel('Time (ms)')
    if i==1
        ylabel([char(941) '(s^{-1})'],'Interpreter','tex')
    end
    xlim([0 inf])
    ylim(limr)
    str = [' Avg = ',num2str(round(meanpts(1),0))];
    text(0,meanpts(1),str,'HorizontalAlignment','left','VerticalAlignment','bottom');
    if maxrate > abs(minrate)
        text(tps(2),maxrate,legendrate{i},'HorizontalAlignment','right','VerticalAlignment','top','Interpreter','tex');
    else
        text(tps(2),minrate,legendrate{i},'HorizontalAlignment','right','VerticalAlignment','bottom','Interpreter','tex');
    end
end

for i=1:4
    p = polyfit(time,strains(:,i),1);
    pv = polyval(p,ts);
    subplot(2,4,i+4)
    plot(tp,strains(:,i))
    hold on
    plot(tps,pv,'--k')
    xlabel('Time (ms)')
    if i==1
        ylabel([char(949) '(mm/mm)'],'Interpreter','tex')
    end
    %ylabel(legendstrain{i},'Interpreter','tex')
    xlim([0 inf])
    ylim(lims)
    str = [' Slope = ',num2str(round(p(1),0))];
    if maxstrain > abs(minstrain)
        text(0,maxstrain,str,'HorizontalAlignment','left','VerticalAlignment','top');
        text(tp(end),minstrain,legendstrain{i},'HorizontalAlignment','right','VerticalAlignment','bottom','Interpreter','tex')
    else
        text(0,minstrain,str,'HorizontalAlignment','left','VerticalAlignment','bottom');
        text(tp(end),maxstrain,legendstrain{i},'HorizontalAlignment','right','VerticalAlignment','top','Interpreter','tex')
    end
end




function edit_strainrate_Callback(hObject, eventdata, handles)
% hObject    handle to edit_strainrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_strainrate as text
%        str2double(get(hObject,'String')) returns contents of edit_strainrate as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    strain_rate = str2double(string_input);
    if isnan(strain_rate)
        set(hObject,'String','');
        user_data.dataset(idx).strainrate = [];
    else
        user_data.dataset(idx).strainrate = strain_rate;
    end
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_strainrate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_strainrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_tension.
function radiobutton_tension_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_tension (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_tension
focus = get(handles.popupmenu_dataset,'Value');
user_data = handles.user_data;

if focus == 1
    set(hObject,'Value',0)
else
    idx = focus - 1;
    if user_data.dataset(idx).stressstate == 1
        set(hObject,'Value',1)
    else
        set(hObject,'Value',0)
    end
end

uiwait(msgbox('The stress state is determined after "Wave Clipping" is complete. This button is not interactive'))

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in radiobutton_compression.
function radiobutton_compression_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_compression (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_compression
focus = get(handles.popupmenu_dataset,'Value');
user_data = handles.user_data;

if focus == 1
    set(hObject,'Value',0)
    return
end

idx = focus - 1;
if user_data.dataset(idx).stressstate == 0
    set(hObject,'Value',1)
else
    set(hObject,'Value',0)
end


uiwait(msgbox('The stress state is determined after "Wave Clipping" is complete. This button is not interactive'))

% Update handles structure
guidata(hObject, handles);
    


% --------------------------------------------------------------------
function plot_display_Callback(hObject, eventdata, handles)
% hObject    handle to plot_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function updateplots(handles,m,n)

% Check to see if the plot panel is clear, if not, clear it
objexist = findobj('Parent', handles.Plot_panel);
if ~isempty(objexist), delete(objexist), end

% load data/bars and shorten addresses
dataset = handles.user_data.dataset;
barsetup = handles.user_data.barsetup;

% Check to see if any data has been imported
if isempty(dataset), return, end

% Check for isolation
iso_idx = find(cell2mat({dataset.plotiso}));

% Check of enabled plots
enable_idx = find(cell2mat({dataset.plotvisability}));

if ~isempty(iso_idx)
    range = iso_idx;
else
    range = enable_idx;
end


% Look though the range and see if each dataset has been preconditioned
% properly
excl = [];
idx = 1;
for i = range
    d = dataset(i);
    if d.null_I == 0 || d.null_T == 0 || isempty(d.rough_crop_indicies) || ...
     isempty(d.wave_length) || isempty(d.length) || isempty(d.area) || ...
     isempty(d.bar_i_idx) || isempty(d.bar_t_idx)
        range(idx) = 0;
        excl = [excl i];
    end
    idx = idx + 1;
end
range(range==0) = [];

% Display msg to user if a dataset hasn't been filled out completely
if ~isempty(excl)
    ex_tag = {dataset(excl).tag};
    str = strjoin(ex_tag,', ');
    msprompt = ['The following datasets were ignored because one (or more) of the following steps was not applied: Rough Crop, Nulling, Wave Clipping, Bar Selection, or Sample Geometry entered. ' str];
    uiwait(msgbox(msprompt,'Datasets Removed from Plot(s)'))
end

% Check to see if any datasets are valid
if isempty(range), return, end

%Index for plotting
j=1;

% Calculate Values to Plot
for i = range
    % Setup bar structures
    barsetup_i = barsetup(dataset(i).bar_i_idx);
    barsetup_t = barsetup(dataset(i).bar_t_idx);

    % function to determine whether or not to invert the signal
    fact_i = dataset(i).invert_i*(-2)+1; % 0/1 = not flipped/flipped
    fact_t = dataset(i).invert_t*(-2)+1; % 0/1 = not flipped/flipped

    % nulled values
    null_i = dataset(i).null_I;
    null_t = dataset(i).null_T;

    % Index start/end
    idxst = [dataset(i).inc_idx dataset(i).refl_idx dataset(i).trans_idx];
    pulse_width = dataset(i).wave_length;
    idxend = idxst + pulse_width;
    
    % cropped voltages
    volt_i = dataset(i).volt_raw_I(idxst(1):idxend(1));
    volt_r = dataset(i).volt_raw_I(idxst(2):idxend(2));
    volt_t = dataset(i).volt_raw_T(idxst(3):idxend(3));

    % Gage Factors
    gf_i = barsetup_i.gagefactor;
    gf_t = barsetup_t.gagefactor;

    % Cropped, (inverted), and nulled, strains
    strain_i = (volt_i - null_i) * fact_i * gf_i;
    strain_r = (volt_r - null_i) * fact_i * gf_i;
    strain_t = (volt_t - null_t) * fact_t * gf_t;

    % Bar Properties (mm^2)
    area_i = (barsetup_i.diameter)^2 * 0.25 * pi;
    area_t = (barsetup_t.diameter)^2 * 0.25 * pi;

    % Moduli (MPa) or (10^6 * kg/ms^2)
    mod_i  = barsetup_i.modulus;
    mod_t  = barsetup_t.modulus;

    % Wave speeds (m/s)
    wspeed_i = barsetup_i.wavespeed;
    wspeed_t = barsetup_t.wavespeed;

    % create time array
    freq = barsetup_i.samplefreq;
    dt = 1/(freq*10^6);
    time = (0:pulse_width)'*dt;

    %run dispersion if activated:
    if any(dataset(i).dispersion_pre) || any(dataset(i).dispersion_man)

        if dataset.dispersion_pre ~=0
            const = [0.5875 , 0.41473, 41.305, 12.208, -9.4836, 3.0893; ...
                     0.58626, 0.41589, 38.715, 13.257, -9.3202, 3.0344; ...
                     0.58499, 0.41708, 36.051, 14.339, -9.1552, 2.9774; ...
                     0.58367, 0.41832, 33.312, 15.458, -8.9934, 2.9202; ...
                     0.58232, 0.41958, 30.564, 16.551, -8.8078, 2.8552; ...
                     0.58092, 0.42088, 27.792, 17.636, -8.6088, 2.7857; ...
                     0.57972, 0.42201, 26.257, 18.005, -8.2969, 2.7116; ...
                     0.5785,  0.42315, 24.674, 18.385, -7.9743, 2.6328; ...
                     0.57724, 0.42434, 23.039, 18.79,  -7.6529, 2.5538; ...
                     0.57594, 0.42555, 21.326, 19.224, -7.3258, 2.4713; ...
                     0.5746,  0.42681, 19.53,  19.702, -7.0054, 2.3897; ...
                     0.57344, 0.4279,  18.668, 19.664, -6.6213, 2.3118; ...
                     0.57228, 0.42901, 17.781, 19.636, -6.2337, 2.2327; ...
                     0.57106, 0.43016, 16.764, 19.679, -5.8543, 2.1532; ...
                     0.56983, 0.43132, 15.741, 19.714, -5.4671, 2.0717; ...
                     0.56855, 0.43254, 14.602, 19.809, -5.0851, 1.9895];
            c_val = const(dataset(i).dispersion_pre,:); 
        else
            c_val = dataset(i).dispersion_man;
        end 
        a_i = barsetup_i.diameter / 1000; % (in meters)
        a_t = barsetup_t.diameter / 1000; % (in meters)
        dist_i = dt * 0.5 * wspeed_i * (idx_st(2) - idx_st(1)); % (in meters)
        dist_t = dt * (idx_st(3)*wspeed_t - idx_st(1)*wspeed_i) - dist_i; % (in meters)
        
        strain_i = applyDispersionCorrection(strain_i,dt,a_i,dist_i,wspeed_i,c_val,1);
        strain_r = applyDispersionCorrection(strain_r,dt,a_i,dist_i,wspeed_i,c_val,0);
        strain_t = applyDispersionCorrection(strain_t,dt,a_t,dist_t,wspeed_t,c_val,0);
    end

    % Force calculation (N)
    force_i = area_i * mod_i * (strain_i + strain_r);
    force_t = area_t * mod_t * strain_t;
    force_3 = (force_i+force_t)/2;

    % Velocity calculations (m/s)
    vel_3 = wspeed_i*(strain_i - strain_r) - wspeed_t*strain_t;
    vel_1 = -2*wspeed_i*strain_r;

    % Displacement calculations (m)
    disp_3 = cumtrapz(vel_3)*dt;
    disp_1 = cumtrapz(vel_1)*dt;
    
    % Specimen Engineering Strain (mm/mm)
    s_length = dataset(i).length/1000; % convert mm to m
    eng_strain3 = disp_3/s_length;
    eng_strain1 = disp_1/s_length;
    
    % Specimen True Strain (mm/mm)
    true_strain3 = log(1+eng_strain3);
    true_strain1 = log(1+eng_strain1);
    
    % Specimen Strain Rate (1/s)
    eng_strain3_rate  = diff(eng_strain3)/dt;
    eng_strain1_rate  = diff(eng_strain1)/dt;
    true_strain3_rate = diff(true_strain3)/dt;
    true_strain1_rate = diff(true_strain1)/dt;
    
    % Add another value at the end to make array length same
    eng_strain3_rate(end+1)  = eng_strain3_rate(end);
    eng_strain1_rate(end+1)  = eng_strain1_rate(end);
    true_strain3_rate(end+1) = true_strain3_rate(end);
    true_strain1_rate(end+1) = true_strain1_rate(end);
    
    % Engineering Stress (Pa)
    s_area = dataset(i).area*10^-6; 
    eng_stress3 = force_i/s_area;
    eng_stress1 = force_t/s_area;
    
    % True Stress
    true_stress3 = eng_stress3.*(1+eng_strain3);
    true_stress1 = eng_stress1.*(1+eng_strain1);
    
    % Check to see if test is compressive. Want to keep all plots in the
    % first quadrant
    ss = dataset(i).stressstate;
    if ss==0 
        ss=-1;
        Plot(j).tag= [dataset(i).tag ' (*C)']; % Alters tag to show test in comp
    else
        Plot(j).tag= dataset(i).tag;
    end
    
    Plot(j).data = [time*ss, eng_strain1, eng_strain3, true_strain1, true_strain3, ...
                    eng_stress1, eng_stress3, true_stress1, true_stress3, ...
                    eng_strain1_rate, eng_strain3_rate, true_strain1_rate, true_strain3_rate, ...
                   disp_1, disp_3, force_t, force_i, force_3, vel_1, vel_3, ...
                   strain_i, strain_r, strain_t]*ss;
    j=j+1;
end

% Create Axis Titles
AxisTitle = {'Time (s)' 'Eng Strain: 1 Wave (mm/mm)' 'Eng Strain: 3 Wave (mm/mm)' ...
    'True Strain: 1 Wave (mm/mm)' 'True Strain: 3 Wave (mm/mm)' 'Eng Stress: 1 Wave (Pa)' 'Eng Stress: 3 Wave (Pa)' ...
    'True Stress: 1 Wave (Pa)' 'True Stress: 3 Wave (Pa)' 'Eng Strain Rate: 1 Wave (1/s)' 'Eng Strain Rate: 3 Wave (1/s)' ...
    'True Strain Rate: 1 Wave (1/s)' 'True Strain Rate: 3 Wave (1/s)' 'Displacement: 1 Wave (m)' 'Displacement: 3 Wave (m)' ...
    'Force: Transmitted Bar (N)' 'Force: Incident Bar (N)' 'Force: Average (N)' ...
    'Velocity: 1 Wave (m/s)' 'Velocity: 3 Wave (m/s)' 'Incident Wave Strain (mm/mm)' ...
    'Reflected Wave Strain (mm/mm)' 'Transmitted Wave Strain (mm/mm)'};

% Create a figure and axes
axes('Parent', handles.Plot_panel)

% Assign amount of plots
if m*n == 6 
    PO = handles.plotorder{1};
elseif m*n == 4
    PO = handles.plotorder{2};
elseif m*n == 2
    PO = handles.plotorder{3};
elseif m*n == 1
    PO = handles.plotorder{4};
end
    
% Generate Legend
for i=1:j-1
    l_text{i} = Plot(i).tag;
end

% initalize string for plot popupbox
sptxt = ['Subplot(' num2str(m) ',' num2str(n) ','];
pltxt = repmat({sptxt},m*n,1);

% Fill out plot pop-up box text
for i = 1:m*n
    pltxt{i} = [pltxt{i} num2str(i) ')'];
end

% function to send subplots to figure pane
send_cal_plots(Plot,PO,l_text,AxisTitle,j,m,n)

pltpck = uicontrol('Parent', handles.Plot_panel,'Style', 'popup',...
    'Units','normalized','Tag','pltpck', ...
    'Position', [.08 0 .15 .03],...
    'String', pltxt, ...
    'Callback', {@plotpick,m,n});

xaxisp = uicontrol('Parent', handles.Plot_panel,'Style', 'popup',...
    'Units','normalized','Tag','xaxis', ...
    'Position', [.28 0 .15 .03],...
    'String', AxisTitle, ...
    'Callback', {@xaxisreplot,Plot,l_text,AxisTitle,j,m,n}); 

yaxisp = uicontrol('Parent', handles.Plot_panel,'Style', 'popup',...
    'Units','normalized','Tag','yaxis', ...
    'Position', [.48 0 .15 .03],...
    'String', AxisTitle, ...
    'Callback', {@yaxisreplot,Plot,l_text,AxisTitle,j,m,n}); 

txtpc = uicontrol('Parent', handles.Plot_panel,'Style','text','Units','normalized',...
        'Position',[0 0 .075 .025],'String','Plot Choice');
    
txtxa = uicontrol('Parent', handles.Plot_panel,'Style','text','Units','normalized',...
        'Position',[.23 0 .05 .025],'String','X-Axis');
    
txtya = uicontrol('Parent', handles.Plot_panel,'Style','text','Units','normalized',...
        'Position',[.43 0 .05 .025],'String','Y-Axis');

% get value of the picked plot
plot_choice = get(pltpck,'Value');
set(xaxisp,'Value',PO(plot_choice,1))
set(yaxisp,'Value',PO(plot_choice,2))
    
    
function plotpick(~,~,m,n)
% import handles
[~,figure] = gcbo;
handles = guidata(figure);

% Find the 3 popup menus
Xaxis = findobj('Parent', handles.Plot_panel,'Tag','xaxis');
Yaxis = findobj('Parent', handles.Plot_panel,'Tag','yaxis');
P_pick = findobj('Parent', handles.Plot_panel,'Tag','pltpck');

% Get the plot choice value
plot_choice = get(P_pick,'Value');

% Assign amount of plots
if m*n == 6 
    PO = handles.plotorder{1};
elseif m*n == 4
    PO = handles.plotorder{2};
elseif m*n == 2
    PO = handles.plotorder{3};
elseif m*n == 1
    PO = handles.plotorder{4};
end

% Updates the X-axis and Y-axis values
set(Xaxis,'Value',PO(plot_choice,1))
set(Yaxis,'Value',PO(plot_choice,2))

function xaxisreplot(~,~,Plot,l_text,AxisTitle,j,m,n)
[~,figure] = gcbo;
handles = guidata(figure);

% Get the x-axis  value
Xaxis = findobj('Parent', handles.Plot_panel,'Tag','xaxis');
x_val = get(Xaxis,'Value');

% Get the plot choice value
P_pick = findobj('Parent', handles.Plot_panel,'Tag','pltpck');
plot_choice = get(P_pick,'Value');

% Assign amount of plots
if m*n == 6 
    handles.plotorder{1}(plot_choice,1) = x_val;
    PO = handles.plotorder{1};
elseif m*n == 4
    handles.plotorder{2}(plot_choice,1) = x_val;
    PO = handles.plotorder{2};
elseif m*n == 2
    handles.plotorder{3}(plot_choice,1) = x_val;
    PO = handles.plotorder{3};
elseif m*n == 1
    handles.plotorder{4}(1,1) = x_val;
    PO = handles.plotorder{4};
end


% Update handles structure
guidata(figure,handles);

send_cal_plots(Plot,PO,l_text,AxisTitle,j,m,n)

function yaxisreplot(~,~,Plot,l_text,AxisTitle,j,m,n)
[~,figure] = gcbo;
handles = guidata(figure);

% Get the y-axis  value
Yaxis = findobj('Parent', handles.Plot_panel,'Tag','yaxis');
y_val = get(Yaxis,'Value');

% Get the plot choice value
P_pick = findobj('Parent', handles.Plot_panel,'Tag','pltpck');
plot_choice = get(P_pick,'Value');

% Assign amount of plots
if m*n == 6 
    handles.plotorder{1}(plot_choice,2) = y_val;
    PO = handles.plotorder{1};
elseif m*n == 4
    handles.plotorder{2}(plot_choice,2) = y_val;
    PO = handles.plotorder{2};
elseif m*n == 2
    handles.plotorder{3}(plot_choice,2) = y_val;
    PO = handles.plotorder{3};
elseif m*n == 1
    handles.plotorder{4}(2) = y_val;
    PO = handles.plotorder{4};
end

% Update handles structure
guidata(figure,handles);

send_cal_plots(Plot,PO,l_text,AxisTitle,j,m,n)

function send_cal_plots(Plot,PO,l_text,AxisTitle,j,m,n)
% Send Calculated Plots
% handles = guidata(gcbo);
% Xaxis = findobj('Parent', handles.Plot_panel,'Tag','xaxis');
% x_str = get(Xaxis,'String');
% x_val = get(Xaxis,'Value');
% x_str{x_val}
% 
% Yaxis = findobj('Parent', handles.Plot_panel,'Tag','yaxis');
% y_str = get(Yaxis,'String');
% y_val = get(Yaxis,'Value');
% y_str{y_val}

for i=1:(n*m)
    subplot(m,n,i)
    for k=1:j-1
        plot(Plot(k).data(:,PO(i,1)),Plot(k).data(:,PO(i,2)))
        hold on
    end
    hold off
    % Display legend in first plot only
    if i==1, legend(l_text), end
    
    % Display Axes
    xlabel(AxisTitle(PO(i,1)));
    ylabel(AxisTitle(PO(i,2)));
end
  

% --- Executes on selection change in popupmenu_i_bar.
function popupmenu_i_bar_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_i_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_i_bar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_i_bar
focus = get(handles.popupmenu_dataset,'Value');
barfocus = get(hObject,'Value');

if focus == 1
    set(handles.popupmenu_i_bar,'Value',1)
    return
end

user_data = handles.user_data;

idx = focus - 1;
user_data.dataset(idx).bar_i_idx = barfocus - 1;

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);

% Replot Wave Wave Clipping (if active)
wave_clipping_replot(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_i_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_i_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu_t_bar.
function popupmenu_t_bar_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_t_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_t_bar contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_t_bar
focus = get(handles.popupmenu_dataset,'Value');
barfocus = get(hObject,'Value');

if focus == 1
    set(handles.popupmenu_t_bar,'Value',1)
    return
end

user_data = handles.user_data;

idx = focus - 1;
user_data.dataset(idx).bar_t_idx = barfocus - 1;

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);

% Replot Wave Wave Clipping (if active)
wave_clipping_replot(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function popupmenu_t_bar_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_t_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_add_bar.
function pushbutton_add_bar_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

msprompt = 'Please input properties for bar setup. Note, as MODULUS, DENSITY, and WAVE SPEED are a function of one another, please leave one of those 3 boxes empty. It will be calculated. Please note the units';
uiwait(msgbox(msprompt,'Input Instructions'))

prompt={'Tag',['Gage Factor (' char(949) '\V)'],'Sampling Frequency (MHz)','Modulus (MPa)','Density (kg/m^3)','Wave Speed (m/s)','Diameter (mm)'};
name = 'Bar Setup';
choice = inputdlg(prompt,name);

if isempty(choice)
    return
end

user_data = handles.user_data;

tag   = choice{1};
gfact = str2double(choice(2));
freq  = str2double(choice(3));
modul = str2double(choice(4));
density  = str2double(choice(5));
speed = str2double(choice(6));
diameter = str2double(choice(7));

if ~isempty(user_data.barsetup)
    % various ways to catch errors inputted into the list box
    if isempty(tag) || any(strcmp({user_data.barsetup.tag}, tag))
        errordlg('Bar must have a unique tag','Input Error')
        return
    end
end

if isnan(gfact) || isnan(freq) || isnan(diameter)
    errordlg('Enter numeric values for gage factor, frequency, and diameter','Input Error')
    return
end

if isnan(modul) && isnan(density+speed)
	errordlg('Enter exactly 2 numberic values only the three options of MODULUS, DENSITY, and WAVE SPEED ','Input Error')
    return
end

if ~isnan(modul+density+speed) || (isnan(density) && isnan(speed))
    errordlg('Enter exactly 2 numberic values only the three options of MODULUS, DENSITY, and WAVE SPEED ','Input Error')
    return
end

% Calculate the missing property
if isnan(modul)
    modul = (speed^2 * density)/10^6;
elseif isnan(density)
    density = (modul/speed^2)*10^6;
else
    speed = (sqrt(modul/density))*1000;
end

if gfact<=0 || freq<=0 || modul<=0 || density<=0 || speed<=0 || diameter<=0
    errordlg('Properties cannot be less than or equal to zero','Input Error')
    return
end

% get the number of bars already in the program
bar_names = get(handles.popupmenu_i_bar,'String');
num_bars = size(bar_names); % this adds a bar automatically since '(select)' is part of the list

% Set index
if isempty(user_data.barsetup)
    idx = 1;
else
    idx = num_bars(1); % this adds a bar automatically since '(select)' is part of the list
end

user_data.barsetup(idx).tag        = tag;
user_data.barsetup(idx).gagefactor = gfact;
user_data.barsetup(idx).samplefreq = freq;   
user_data.barsetup(idx).modulus    = modul;
user_data.barsetup(idx).density    = density;
user_data.barsetup(idx).wavespeed  = speed;
user_data.barsetup(idx).diameter   = diameter; %(mm)

% update the list in the pop up menu for the bars
popdisp={'(select)',user_data.barsetup.tag};
set(handles.popupmenu_i_bar,'String',popdisp);
set(handles.popupmenu_t_bar,'String',popdisp);

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_edir_bar.
function pushbutton_edir_bar_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_edir_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
user_data = handles.user_data;

if isempty(user_data.barsetup) || isempty(user_data.barsetup(1).tag)
    errordlg('Please Create a bar prior to editing','No bar to Edit')
    return
end

str = get(handles.popupmenu_i_bar,'String');

[idx,v] = listdlg('PromptString','Select a bar to edit:',...
                'SelectionMode','single',...
                'ListString',{str{2:end}});
            
if v==0
    return
end

% Set Values
tag = user_data.barsetup(idx).tag;      
gfact = user_data.barsetup(idx).gagefactor;
freq = user_data.barsetup(idx).samplefreq;   
modul = user_data.barsetup(idx).modulus;
density = user_data.barsetup(idx).density;
speed = user_data.barsetup(idx).wavespeed;
diameter = user_data.barsetup(idx).diameter;

% Instruction Prompt
msprompt = 'Please edit properties for bar setup. Note, as MODULUS, DENSITY, and WAVE SPEED are a function of one another, please leave one of those 3 boxes empty. The remaining value will be calculated using the relationship c^2 = E/\rho. Please note the units';
CreateStruct.Interpreter = 'tex';
CreateStruct.WindowStyle = 'modal';
uiwait(msgbox(msprompt,'Input Instructions',CreateStruct))

% Edit box prompt
num_lines = 1;
defaultans = {tag,num2str(gfact),num2str(freq),num2str(modul),num2str(density),'',num2str(diameter)};
prompt={'Tag',['Gage Factor (' char(949) '\V)'],'Sampling Frequency (MHz)','Modulus (MPa)','Density (kg/m^3)','Wave Speed (m/s)','Diameter (mm)'};
title = 'Bar Setup';
choice = inputdlg(prompt,title,num_lines,defaultans);

if isempty(choice)
    return
end

tag   = choice{1};
gfact = str2double(choice(2));
freq  = str2double(choice(3));
modul = str2double(choice(4));
density  = str2double(choice(5));
speed = str2double(choice(6));
diameter = str2double(choice(7));

% Need to remove the name from the search that makes sure there are no
% dublicate names
oldnames = {user_data.barsetup.tag};
oldnames(idx) = [];

% various ways to catch errors inputted into the list box
if isempty(tag) || any(strcmp(oldnames, tag))
    errordlg('Bar must have a unique tag','Input Error')
    return
end

if isnan(gfact) || isnan(freq) || isnan(diameter)
    errordlg('Enter numeric values for gage factor, frequency, and diameter','Input Error')
    return
end

if isnan(modul) && isnan(density+speed)
	errordlg('Enter exactly 2 numberic values only the three options of MODULUS, DENSITY, and WAVE SPEED ','Input Error')
    return
end

if ~isnan(modul+density+speed) || (isnan(density) && isnan(speed))
    errordlg('Enter exactly 2 numberic values only the three options of MODULUS, DENSITY, and WAVE SPEED ','Input Error')
    return
end

% Calculate the missing property
if isnan(modul)
    modul = (speed^2 * density)/10^6;
elseif isnan(density)
    density = (modul/speed^2)*10^6;
else
    speed = (sqrt(modul/density))*1000;
end

if gfact<=0 || freq<=0 || modul<=0 || density<=0 || speed<=0 || diameter<=0
    errordlg('Properties cannot be less than or equal to zero','Input Error')
    return
end

% Update with new values
user_data.barsetup(idx).tag        = tag;
user_data.barsetup(idx).gagefactor = gfact;
user_data.barsetup(idx).samplefreq = freq;   
user_data.barsetup(idx).modulus    = modul;
user_data.barsetup(idx).density    = density;
user_data.barsetup(idx).wavespeed  = speed;
user_data.barsetup(idx).diameter   = diameter;

% update the list in the pop up menu for the bars
popdisp={'(select)',user_data.barsetup.tag};
set(handles.popupmenu_i_bar,'String',popdisp);
set(handles.popupmenu_t_bar,'String',popdisp);

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


function edit_length_Callback(hObject, eventdata, handles)
% hObject    handle to edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_length as text
%        str2double(get(hObject,'String')) returns contents of edit_length as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    usr_len = str2double(string_input);
    if isnan(usr_len)
        set(hObject,'String','');
        user_data.dataset(idx).length = [];
    else
        user_data.dataset(idx).length = usr_len;
    end
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_length_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_length (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_area_Callback(hObject, eventdata, handles)
% hObject    handle to edit_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_area as text
%        str2double(get(hObject,'String')) returns contents of edit_area as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    usr_area = str2double(string_input);
    if isnan(usr_area)
        set(hObject,'String','');
        set(handles.edit_diameter,'String','')
        user_data.dataset(idx).area = [];
    else
        user_data.dataset(idx).area = usr_area;
        diameter = 2*sqrt(usr_area/pi);
        set(handles.edit_diameter,'String',num2str(diameter))
    end
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit_area_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_area (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_diameter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_diameter as text
%        str2double(get(hObject,'String')) returns contents of edit_diameter as a double
user_data = handles.user_data;

string_input = get(hObject,'String');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1
    set(hObject,'String','');
else
    idx = focus - 1;
    usr_dia = str2double(string_input);
    if isnan(usr_dia)
        set(hObject,'String','');
        set(handles.edit_area,'String','')
        user_data.dataset(idx).area = [];
    else
        area = pi*(usr_dia/2)^2;
        user_data.dataset(idx).area = area;
        set(handles.edit_area,'String',num2str(area))
    end
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit_diameter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_diameter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton_disp_p.
function radiobutton_disp_p_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_disp_p (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_disp_p
value = get(hObject,'Value');
focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

if value == 1
    nu_value = get(handles.popupmenu_disp,'Value');
    if nu_value == 1 % accounting for '(select)'
        nu_value = 2;
        set(handles.popupmenu_disp,'Value',2);
    end
    dataset.dispersion_pre = nu_value - 1; % have to shift back 1 due to the 'select' space
    dataset.dispersion_man = [];
    set(handles.radiobutton_disp_m,'Value',0)
else
    dataset.dispersion_pre = [];
end

handles.user_data.dataset(idx) = dataset;

% Update handles structure
guidata(hObject, handles);

wave_clipping_replot(hObject, eventdata, handles)

% --- Executes on button press in radiobutton_disp_m.
function radiobutton_disp_m_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton_disp_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton_disp_m
value = get(hObject,'Value');
focus = get(handles.popupmenu_dataset,'Value');

user_data = handles.user_data;

if focus == 1 % no dataset is selected
    set(hObject,'Value',0);
else 
    idx = focus - 1;
    if value == 1
        set(handles.radiobutton_disp_p,'Value',0)
        set(handles.popupmenu_disp,'Value',1)
        x = inputdlg({'A','B','C','D','E','F'}, 'Manual Dispersion Entry'); % Enter A-F numeric values
        x_array = cellfun(@str2double,x);
        if any(isnan(x_array)) % Need to have numeric values entered
            user_data.dataset(idx).dispersion_man = [];
            errordlg('Values must be numeric. Manual dispersion recorded','Dispersion Entry Error');
            set(handles.radiobutton_disp_m,'Value',0)
        else
            user_data.dataset(idx).dispersion_man = x_array;
        end
        user_data.dataset(idx).dispersion_pre = [];    
    else
        user_data.dataset(idx).dispersion_man = [];
    end
end

handles.user_data = user_data;

% Update handles structure
guidata(hObject, handles);

wave_clipping_replot(hObject, eventdata, handles)

% --- Executes on selection change in popupmenu_disp.
function popupmenu_disp_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_disp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_disp

focus = get(handles.popupmenu_dataset,'Value');

if focus == 1 % no dataset is selected
    set(hObject,'Value',1);
    return
end

value = get(hObject,'Value');

% Need the Predefined button to be enabled for any action to occur
if get(handles.radiobutton_disp_p,'Value') == 0
    return
end

idx = focus - 1;
dataset = handles.user_data.dataset(idx);

if value == 1
    set(hObject,'Value',2)
    dataset.dispersion_pre = 1;
else
    dataset.dispersion_pre = value - 1; % takes into account '(select)' in first slot
end

handles.user_data.dataset(idx) = dataset;

% Update handles structure
guidata(hObject, handles);

wave_clipping_replot(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_disp_m.
function pushbutton_disp_m_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_disp_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function wave_clipping_replot(hObject, eventdata, handles)
% find sliders
s_i=findobj('Parent', handles.Plot_panel,'Tag','slider_i');
if isempty(s_i), return, end

s_r=findobj('Parent', handles.Plot_panel,'Tag','slider_r');
s_t=findobj('Parent', handles.Plot_panel,'Tag','slider_t');
s_l=findobj('Parent', handles.Plot_panel,'Tag','slider_l');



% extract slider values
idx_st      = [get(s_i,'Value') get(s_r,'Value') get(s_t,'Value')];
pulse_width = get(s_l,'Value');

% Function call to plot calculated values
replot_clips(hObject,idx_st,pulse_width)


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isfield(handles, 'UIpositions'), return, end

% figure/window old position
tag = get(hObject, 'Tag');
oldPos = handles.UIpositions.(tag).Position;
%display( sprintf('Was: %s @[x=%g y=%g w=%g h=%g]', tag, oldPos) )

% figure's new Position
oldUnits = get(hObject, 'Units');
set(hObject, 'Units', 'characters')
newPos = get(hObject, 'Position');
%display( sprintf('Now: %s @ [x=%g y=%g w=%g h=%g]', tag, newPos) )

% reject smaller figure size
if newPos(3)<oldPos(3) || newPos(4)<oldPos(4)
    set(hObject, 'Position', oldPos)
    yOffset = 0;
else
    yOffset = newPos(4) - oldPos(4);
end
set(hObject, 'Units', oldUnits)
 %display(yOffset)

objList = findobj( 'Type', 'uipanel', ...
    '-or', 'Tag', 'text2', ...
    '-or', 'Tag', 'popupmenu_dataset');

% UI controls
for i=1:length(objList)
    tag = get(objList(i), 'Tag');

    if isempty(tag), continue, end
    if ~isfield(handles.UIpositions, tag), continue, end
    if ~isfield(handles.UIpositions.(tag), 'Position'), continue, end
    if ~strcmp(tag,'Plot_panel') && ~strcmp(tag,'uipanel_incident') && ~strcmp(tag,'uipanel_trans') 
        % remember Units
        oldUnits = get(objList(i), 'Units');

        % set Units temporarily to characters
        set(objList(i), 'Units', 'characters');

        % re-position 
        current = handles.UIpositions.(tag).Position;    

        % revise y-coordinate
        current(2) = current(2) + yOffset;
        set(objList(i), 'Position', current )

        % restore Units
        set(objList(i), 'Units', oldUnits);
    end
end

% plot panel
obj = findobj('Tag', 'Plot_panel');

% remember Units
oldUnits = get(obj, 'Units');

% set Units temporarily to characters
set(obj, 'Units', 'characters');

% re-position
current = get(obj, 'Position');
xOffset = current(1) - handles.UIpositions.Plot_panel.Position(1);

current(1) = handles.UIpositions.Plot_panel.Position(1);
current(3) = current(3) + xOffset;

set(obj, 'Position', current )
set(obj, 'Units', oldUnits )


% --- Executes on button press in pushbutton_remove_bar.
function pushbutton_remove_bar_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove_bar (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

barsetup = handles.user_data.barsetup;
dataset = handles.user_data.dataset;

if isempty(barsetup)
    errordlg('Please Create a bar prior to removing one','No bar to remove')
    return
end

str = get(handles.popupmenu_i_bar,'String');

[idx,v] = listdlg('PromptString','Select a bar to edit:',...
                'SelectionMode','single',...
                'ListString',{str{2:end}});
            
if v==0
    return
end

if ~isempty(dataset)
    % Update datasets to point to correct bar index
    num_data = {dataset.tag};

    for i=1:length(num_data)
        if dataset(i).bar_i_idx == idx
            dataset(i).bar_i_idx = [];
            flag = 1;
        elseif dataset(i).bar_i_idx > idx % have to shift down a bar
            dataset(i).bar_i_idx = dataset(i).bar_i_idx - 1;
            flag = 1;
        end
        if dataset(i).bar_t_idx == idx
            dataset(i).bar_t_idx = [];
            flag = 1;
        elseif dataset(i).bar_t_idx > idx % have to shift down a bar
            dataset(i).bar_t_idx = dataset(i).bar_t_idx - 1;
            flag = 1;
        end
    end
end

% Remove the chosen Bar
barsetup(idx) = [];

% update the list in the pop up menu for the bars
popdisp={'(select)',barsetup.tag};
set(handles.popupmenu_i_bar,'String',popdisp);
set(handles.popupmenu_t_bar,'String',popdisp);

% Need to update the view in a bar was removed that was visable
if exist('flag','var')
    focus = get(handles.popupmenu_dataset,'Value');
    if focus == 1
        a = 1;
    else
        idx2 = focus - 1; 
        if isempty(dataset(idx2).bar_i_idx)
            set(handles.popupmenu_i_bar,'Value',1);
        else
            set(handles.popupmenu_i_bar,'Value',1 + dataset(idx2).bar_i_idx);
        end
        if isempty(dataset(idx2).bar_t_idx)
            set(handles.popupmenu_t_bar,'Value',1);
        else
            set(handles.popupmenu_t_bar,'Value',1 + dataset(idx2).bar_t_idx);
        end
    end
end

handles.user_data.dataset = dataset;
handles.user_data.barsetup = barsetup;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in checkbox_rc.
function checkbox_rc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_rc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_rc


% --- Executes on button press in checkbox_wc.
function checkbox_wc_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_wc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_wc


% --------------------------------------------------------------------
function plot23_Callback(hObject, eventdata, handles)
% hObject    handle to plot23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplots(handles,2,3)

% --------------------------------------------------------------------
function plot22_Callback(hObject, eventdata, handles)
% hObject    handle to plot22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplots(handles,2,2)

% --------------------------------------------------------------------
function plot21_Callback(hObject, eventdata, handles)
% hObject    handle to plot21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplots(handles,2,1)

% --------------------------------------------------------------------
function plot12_Callback(hObject, eventdata, handles)
% hObject    handle to plot12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplots(handles,1,2)

% --------------------------------------------------------------------
function plot11_Callback(hObject, eventdata, handles)
% hObject    handle to plot11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateplots(handles,1,1)


% --- Executes on button press in pushbutton_doc.
function pushbutton_doc_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_doc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://icme.hpc.msstate.edu/mediawiki/index.php/Code:_SHPB_Analysis','-browser')

% --- Executes on button press in pushbutton_video.
function pushbutton_video_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://youtu.be/iLyfXR0xYJ0','-browser')

% --- Executes on button press in pushbutton_pubsite.
function pushbutton_pubsite_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pubsite (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
web('https://doi.org/10.1007/s11340-016-0191-9','-browser')
