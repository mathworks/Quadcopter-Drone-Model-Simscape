%% Script to create protected model
%  with Simscape runtime parameters.

% Copyright 2021 The MathWorks(TM), Inc.

% Move to folder where script is saved
cd(fileparts(which(mfilename)));

% Open and configure model
mdl = 'quadcopter_package_delivery';
new_mdl = [mdl '_MRPM_Start'];
refsys = [new_mdl '/Quadcopter'];
refmdl = 'Quadcopter';

open_system(mdl);
save_system(mdl,new_mdl);
set_param(new_mdl,'SaveFormat','Structure');


%% Block paths
tunebpathA = [new_mdl '/Quadcopter/Load/Medical Kit/Medical Kit'];
refsys = [new_mdl '/Quadcopter'];

%% Define Simulink.Parameter objects
pkgDensity = Simulink.Parameter;
pkgDensity.CoderInfo.StorageClass = 'SimulinkGlobal';
pkgDensity.Value = 5;%evalin('base',get_param(tunebpathA,'Density'));

%% Create Reference Model
set_param(refsys,'TreatAsAtomicUnit','on');
warning off Simulink:modelReference:convertToModelReference_inportInvalidDownStreamSampleTimeErr
warning off Simulink:modelReference:ProtectedModelCallbackLostWarning

Simulink.SubSystem.convertToModelReference(...
   refsys,refmdl, ...
   'AutoFix',true,...
   'ReplaceSubsystem',true);

%% Configure Reference Model
open_system(refmdl);
set_param(refmdl,'SimscapeLogType','none');
set_param(refmdl,'ModelReferenceNumInstancesAllowed','single');
%set_param(refmdl,'ModelReferenceMinAlgLoopOccurrences','on');

save_system(refmdl);

%% Create and reference protected model
[harnessHandle, neededVars] = Simulink.ModelReference.protect(refmdl, 'Harness', false, 'Webview',true);
set_param(refsys,'ModelName',[refmdl '.slxp']);
bdclose(refmdl);

%% Run simulation with two parameter values

% Custom settings
%set_param(new_mdl,'ModelReferenceMinAlgLoopOccurrences','on');
ph = get_param([new_mdl '/Quadcopter'],'PortHandles');
set_param(ph.Outport(1),...
    'DataLogging','on',...
    'DataLoggingNameMode','Custom',...
    'DataLoggingName','Quadcopter');

pkgDensity.Value = 100;
sim(new_mdl);
outA1 = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz;

pkgDensity.Value = 200;
sim(new_mdl);
outA2 = logsout_quadcopter_package_delivery.get('Quadcopter').Values.Chassis.pz;

ref_pxyz = logsout_quadcopter_package_delivery.get('Ref').Values.pos;

figure(1); clf;
plot(ref_pxyz.Time,ref_pxyz.Data(:,3),'k--','LineWidth',2);
hold on
plot(outA1.Time,outA1.Data,'LineWidth',1);
plot(outA2.Time,outA2.Data,'LineWidth',1);
hold off

title('Package Height During Maneuver');
xlabel('Time (s');ylabel('Load Height (m)');
legend({'Command','Normal','Heavy'},'Location','Best');

%% Cleanup directory
%{

bdclose(new_mdl); 
delete([new_mdl '.slx']);
bdclose(refmdl);
delete([refmdl '.slx']);
delete([refmdl '.slxp']);
delete([refmdl '*.mexw64']);

%}
clear pkgDensity
pkgDensity = 160;