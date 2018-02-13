%% Upload training data to Cloud bucket and package tensorflow detection code

function obj = Traininit(obj, varargin )
% check if you are under the right project
cmd = sprintf('gcloud config get-value project');
[~, result] = system(cmd);
result = result(1:24);
if ~strcmp(result, obj.ProjectName)
    cmd = sprintf('gcloud config set project %s',obj.ProjectName);
    system(cmd);
end
%Upload data to cloudbucket

cmd = sprintf('gsutil cp %s  %s/data/train.record', obj.Train_record, obj.Cloudfolder);
[status, result]=system(cmd);
if ~status, fprintf('%s uploaded as train.record',obj.Train_record);
else
    fprintf('%s failed to upload',obj.Train_record)
end
cmd = sprintf('gsutil cp %s  %s/data/val.record', obj.Val_record,obj.Cloudfolder);
[status, result]=system(cmd);
if ~status,fprintf('%s successfully uploaded as val.record',obj.Val_record);
else
    fprintf('%s failed to upload',obj.Val_record)
end
cmd = sprintf('gsutil cp %s  %s/data/label_map.pbtxt', obj.Label_map,obj.Cloudfolder);
[status, result]=system(cmd);
if ~status,fprintf('%s successfully uploaded',obj.Label_map);
else
    fprintf('%s failed to upload',obj.Label_map)
end
    
cmd = sprintf('gsutil cp %s/model.ckpt.*  %s/data', obj.Pretrain_model, obj.Cloudfolder);
[status, result]=system(cmd);
if ~status,fprintf('%s successfully uploaded',obj.Pretrain_model)
else
    fprintf('%s failed to upload',obj.Pretrain_model)
end
    
%Edit the faster_rcnn_resnet101_pets.config template. Please note that there
%are multiple places where PATH_TO_BE_CONFIGURED needs to be set to the working dir.
cmd1=sprintf(' "s|PATH_TO_BE_CONFIGURED|"%s"/data|g" %s',...
obj.Cloudfolder,obj.NetworkConfig);
cmd=strcat('sed -i ''','''',cmd1);
[status, result]=system(cmd);
[~,network]=fileparts(obj.NetworkConfig);
cmd = sprintf('gsutil cp %s  %s/data/%s.config', obj.NetworkConfig,...
    obj.Cloudfolder,network);
[status, result]=system(cmd);
if ~status,fprintf('%s successfully uploaded',obj.NetworkConfig)
else
    fprintf('%s failed to upload',obj.NetworkConfig)
end
% Edit the path back to undefined status.
cmd1=sprintf(' "s|%s/data|"PATH_TO_BE_CONFIGURED"|g" %s',...
obj.Cloudfolder,obj.NetworkConfig);
cmd=strcat('sed -i ''','''',cmd1);
[status, result]=system(cmd);

% package Tensorflow Object Detection code
currentpath = pwd;
if ~exist(fullfile(obj.TFmodels,'dist/object_detection-0.1.tar.gz'), 'file')
    cd (obj.TFmodels);
    cmd = sprintf('python setup.py sdist');
    [status, result]=system(cmd);
    cd(currentpath);
end
if ~exist(fullfile(obj.TFmodels,'slim/dist/slim-0.1.tar.gz'), 'file')
    cd (obj.TFmodels);
    cd slim;
    cmd = sprintf('python slim/setup.py sdist');
    [status, result]=system(cmd);
    cd(currentpath);
end
end