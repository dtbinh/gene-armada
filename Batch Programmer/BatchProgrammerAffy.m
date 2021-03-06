function varargout = BatchProgrammerAffy(varargin)
% BATCHPROGRAMMERAFFY M-file for BatchProgrammerAffy.fig
%      BATCHPROGRAMMERAFFY, by itself, creates a new BATCHPROGRAMMERAFFY or raises the existing
%      singleton*.
%
%      H = BATCHPROGRAMMERAFFY returns the handle to a new BATCHPROGRAMMERAFFY or the handle to
%      the existing singleton*.
%
%      BATCHPROGRAMMERAFFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BATCHPROGRAMMERAFFY.M with the given input arguments.
%
%      BATCHPROGRAMMERAFFY('Property','Value',...) creates a new BATCHPROGRAMMERAFFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BatchProgrammerAffy_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BatchProgrammerAffy_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BatchProgrammerAffy

% Last Modified by GUIDE v2.5 19-Nov-2008 19:32:48

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BatchProgrammerAffy_OpeningFcn, ...
                   'gui_OutputFcn',  @BatchProgrammerAffy_OutputFcn, ...
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
% End initialization code - DO NOT EDIT


% --- Executes just before BatchProgrammerAffy is made visible.
function BatchProgrammerAffy_OpeningFcn(hObject, eventdata, handles, varargin)

% Set Window size and Position
screensize=get(0,'screensize');                       
winsize=get(handles.BatchProgrammerAffy,'Position');
winwidth=winsize(3);
winheight=winsize(4);
screenwidth=screensize(3);                           
screenheight=screensize(4);                           
winpos=[0.5*(screenwidth-winwidth),0.5*(screenheight-winheight),winwidth,winheight];                          
set(handles.BatchProgrammerAffy,'Position',winpos);

% Get input
handles.datstruct=varargin{1};
handles.cdfstruct=varargin{2};
handles.experimentInfo=varargin{3};
handles.Project=varargin{4};

% Initialize indexes for creating analysis objects and current selection
handles.analysisIndex=0;
handles.currentIndex=1;
% Initialize boolean to indicate if something changed (useful for exiting)
handles.somethingChanged=false;

% There is no reason to set default outputs as the Run button won't be activated
% until some settings are set. We define only some boolean variables in order to
% control which stage has been set and consequently what will be run.
handles.sets.backnormsumSet=false; % Background adjustment/normalization/summ not set
handles.sets.filterSet=false;   % Filtering conditions not set
handles.sets.selcondSet=false;  % Selected subsets not set
handles.sets.statSet=false;     % Statistical sets not set
handles.sets.clusterSet=false;  % Clustering not set
% ...and the handles contents
handles.backnormsum=[];
handles.filtering=[];
handles.selectconditions=[];
handles.statistics=[];
handles.clustering=[];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BatchProgrammerAffy wait for user response (see UIRESUME)
% uiwait(handles.BatchProgrammerAffy);


% --- Outputs from this function are returned to the command line.
function varargout = BatchProgrammerAffy_OutputFcn(hObject, eventdata, handles) 


function file_Callback(hObject, eventdata, handles)


function fileNew_Callback(hObject, eventdata, handles)

% Get a name for the batch
[filename,pathname]=uiputfile({'*.abf','ARMADA Batch Files'},'New Batch');
if filename==0
    uiwait(msgbox('No file specified','Batch','modal'));
    return
else
    handles=reinit(handles); % Delete old project
    if ~isempty(strfind(filename,'.abf'))
        handles.filename=strcat(pathname,filename);
    else
        handles.filename=strcat(pathname,filename,'.abf');
    end
end

try
    newproj=handles.filename;
    name=handles.filename;
    save(newproj,'name');
    % Activate Save etc.
    set(handles.fileSave,'Enable','on')
    set(handles.fileSaveAs,'Enable','on')
    % Allow background correction button
    set(handles.backNormSumButton,'Enable','on')
catch
    oops={'An error occured while trying to save the following file',...
          newproj,...
          lasterr};
    uiwait(errordlg(oops,'Error Saving File...','modal'));
end

guidata(hObject,handles);


function fileOpen_Callback(hObject, eventdata, handles)

try
    
    [fPrevious,fprevpath]=uigetfile({'*.abf','ARMADA Batch Files'},'Open Batch');
    if fPrevious==0
        uiwait(msgbox('No File was selected','Open'));
        return
    end
    
    % If not cancel remove any data being currently processed
    handles=reinit(handles); % Delete old project
    
    fPrevious=strcat(fprevpath,fPrevious);
    S=load('-mat',fPrevious);
    
    if isfield(S,'name')
        handles.filename=S.name;
    end
    if isfield(S,'analysisIndex')
        handles.analysisIndex=S.analysisIndex;
    end
    if isfield(S,'sets')
        handles.sets=S.sets;
    end
    if isfield(S,'backnormsum')
        handles.backnormsum=S.backnormsum;
    end
    if isfield(S,'filtering')
        handles.filtering=S.filtering;
    end
    if isfield(S,'selectconditions')
        handles.selectconditions=S.selectconditions;
    end
    if isfield(S,'statistics')
        handles.statistics=S.statistics;
    end
    if isfield(S,'clustering')
        handles.clustering=S.clustering;
    end
    
    % Fill analysis objects listbox and manage buttons that require analysis steps to have
    % been performed
    if ~isempty(handles.selectconditions)
        anal=cell(length(handles.selectconditions),1);
        for i=1:length(handles.selectconditions)
            anal{i}=['Analysis ',num2str(i)];
        end
        set(handles.analysisList,'String',anal,'Value',1)
        set(handles.listContextView,'Enable','on')
        set(handles.listContextDelete,'Enable','on')
    end
    
    % Enable buttons
    set(handles.backNormSumButton,'Enable','on')
    if handles.sets.backnormsumSet
        set(handles.filteringButton,'Enable','on')
    end
    if handles.sets.filterSet
        set(handles.selCondButton,'Enable','on')
        set(handles.runButton,'Enable','on')
    end
    if handles.sets.selcondSet
        set(handles.statButton,'Enable','on')
    end
    if handles.sets.statSet
        set(handles.clusterButton,'Enable','on')
    end
       
    % Manage menus
    set(handles.fileSave,'Enable','on')
    set(handles.fileSaveAs,'Enable','on')
    
    % Load all parameters by updating handles structure
    guidata(hObject,handles);    
    
catch
    opmsg={'An error occured while trying to open the following file',...
           fPrevious,...
           'Make sure that this is a valid ARMADA batch file',...
           lasterr};
    uiwait(errordlg(opmsg,'Failed to open File','modal'));
    return
end


function fileSave_Callback(hObject, eventdata, handles)

appended=handles.filename;
% Filename always exists
name=handles.filename;
strsave='''name''';
if isfield(handles,'analysisIndex')
    analysisIndex=handles.analysisIndex;
    strsave=[strsave,',','''analysisIndex'''];
end
if isfield(handles,'sets')
    sets=handles.sets;
    strsave=[strsave,',','''sets'''];
end
if isfield(handles,'backnormsum')
    backnormsum=handles.backnormsum;
    strsave=[strsave,',','''backnormsum'''];
end
if isfield(handles,'filtering')
    filtering=handles.filtering;
    strsave=[strsave,',','''filtering'''];
end
if isfield(handles,'selectconditions')
    selectconditions=handles.selectconditions;
    strsave=[strsave,',','''selectconditions'''];
end
if isfield(handles,'statistics')
    statistics=handles.statistics;
    strsave=[strsave,',','''statistics'''];
end
if isfield(handles,'clustering')
    clustering=handles.clustering;
    strsave=[strsave,',','''clustering'''];
end
strsave=['save(appended,',strsave,');'];

try 
    eval(strsave)
    % Indicate that changes were saved
    handles.somethingChanged=false;
    guidata(hObject,handles);
catch
    errmsg={'An error occured while trying to save the batch file.',...
            appended,...
            'Please review your settings or report the following error:',...
            lasterr};
    uiwait(errordlg(errmsg,'Error Saving Batch File'));
end


function fileSaveAs_Callback(hObject, eventdata, handles)

% Get a name for the new batch to be saved
[newfilename,newpathname,findex]=uiputfile({'*.abf','ARMADA Batch Files (*.abf)';...
                                            '*.apj','ARMADA Project Files (*.apj)'},...
                                            'Save Batch File As...');
if newfilename==0
    uiwait(msgbox('No file specified','Batch','modal'));
    return
else
    newfile=strcat(newpathname,newfilename);
    switch findex
        
        case 1 % Batch files
            
            % Project always exists
            name=newfilename;
            strsave='''name''';
            if isfield(handles,'analysisIndex')
                analysisIndex=handles.analysisIndex;
                strsave=[strsave,',','''analysisIndex'''];
            end
            if isfield(handles,'sets')
                sets=handles.sets;
                strsave=[strsave,',','''sets'''];
            end
            if isfield(handles,'backnormsum')
                backnormsum=handles.backnormsum;
                strsave=[strsave,',','''backnormsum'''];
            end
            if isfield(handles,'filtering')
                filtering=handles.filtering;
                strsave=[strsave,',','''filtering'''];
            end
            if isfield(handles,'selectconditions')
                selectconditions=handles.selectconditions;
                strsave=[strsave,',','''selectconditions'''];
            end
            if isfield(handles,'statistics')
                statistics=handles.statistics;
                strsave=[strsave,',','''statistics'''];
            end
            if isfield(handles,'clustering')
                clustering=handles.clustering;
                strsave=[strsave,',','''clustering'''];
            end
            strsave=['save(newfile,',strsave,');'];

            try
                eval(strsave)
            catch
                errmsg={'An error occured while trying to save batch file',...
                        newfile,...
                        'Please review your settings or report the following error:',...
                        lasterr};
                uiwait(errordlg(errmsg,'Error Saving Batch File'));
            end
            
        case 2 % Conversion to ARMADA project files
            
%             try

                % Part 1 - Overall items
                % We have to save the following items... handles.datstruct, handles.gnID,
                % handles.experimentInfo,handles.cdfstruct.  Also the select conditions 
                % index... this at the end.
                stru.version=2;
                stru.datstruct=handles.datstruct;
                stru.cdfstruct=handles.cdfstruct;
                stru.experimentInfo=handles.experimentInfo;
                stru.gnID=handles.gnID;
                stru.mainmsg=cellstr('Project created from batch file');

                % Part 2 - Specific analysis items... We need to create and save several
                % items...
                % The first analysis part contains the whole normalization etc. but no other
                % data on statistics etc. These are done as separate select conditions parts.

                % Fill the first analysis including all preprocessing steps
                analysis(1).exprp=handles.experimentInfo.exprp;
                analysis(1).numberOfConditions=handles.experimentInfo.numberOfConditions;
                analysis(1).conditionNames=handles.experimentInfo.conditionNames;
                analysis(1).conditions=1:handles.experimentInfo.numberOfConditions;
                analysis(1).BackAdj=handles.backnormsum.backmethod;
                analysis(1).BackAdjOpts=handles.backnormsum.backopts;
                analysis(1).Norm=handles.backnormsum.normmethod;
                analysis(1).NormOpts=handles.backnormsum.normopts;
                analysis(1).Sum=handles.backnormsum.summmethod;
                analysis(1).SumOpts=handles.backnormsum.summopts;
                analysis(1).exptab=handles.exptab;
                analysis(1).TotalBadpoints=handles.TotalBadpoints;
                analysis(1).DataCellNormLo=handles.DataCellNormLo;
                analysis(1).DataCellFiltered=[];
                analysis(1).DataCellStat=[];
                analysis(1).FinalTable=[];
                analysis(1).Clusters=[];
                analysis(1).PIndex=[];
                analysis(1).Centroids=[];
                analysis(1).group=[];

                % Fill the rest with the performed analyses from the batch
                for i=2:length(handles.selectconditions)+1
                    
                    analysis(i).exprp=handles.selectconditions(i-1).exprp;
                    analysis(i).numberOfConditions=handles.selectconditions(i-1).number;
                    analysis(i).conditionNames=handles.selectconditions(i-1).names;
                    analysis(i).conditions=handles.selectconditions(i-1).index;
                    
                    analysis(i).BackAdj=handles.backnormsum.backmethod;
                    analysis(i).BackAdjOpts=handles.backnormsum.backopts;
                    analysis(i).Norm=handles.backnormsum.normmethod;
                    analysis(i).NormOpts=handles.backnormsum.normopts;
                    analysis(i).Sum=handles.backnormsum.summmethod;
                    analysis(i).SumOpts=handles.backnormsum.summopts;

                    tempexp=cell(1,handles.selectconditions(i-1).number);
                    tempbad=cell(1,handles.selectconditions(i-1).number);
                    for j=1:handles.selectconditions(i-1).number
                        tempexp{j}=handles.exptab{handles.selectconditions(i-1).index(j)}...
                            (handles.selectconditions(i-1).repindex{j});
                        tempbad{j}=handles.TotalBadpoints{handles.selectconditions(i-1).index(j)}...
                            (handles.selectconditions(i-1).repindex{j});
                    end

                    analysis(i).exptab=tempexp;
                    analysis(i).TotalBadpoints=tempbad;
                    analysis(i).DataCellNormLo=handles.results(i-1).DataCellNormLo;
                    
                    if isfield(handles,'results')
                        if isfield(handles.results,'DataCellFiltered') && ~isempty(handles.results(i-1).DataCellFiltered)
                            analysis(i).DataCellFiltered=handles.results(i-1).DataCellFiltered;
                            analysis(i).DataCellStat=handles.results(i-1).DataCellStat;
                        end
                        if isfield(handles.results,'FinalTable') && ~isempty(handles.results(i-1).FinalTable)
                            analysis(i).FinalTable=handles.results(i-1).FinalTable;
                            analysis(i).Clusters=handles.results(i-1).Clusters;
                            analysis(i).PIndex=handles.results(i-1).PIndex;
                            if isfield(handles.results(i-1),'Centroids') && ~isempty(handles.results(i-1).Centroids)
                                analysis(i).Centroids=handles.results(i-1).Centroids;
                            end
                            if isfield(handles.results(i-1),'group') && ~isempty(handles.results(i-1).group)
                                analysis(i).group=handles.results(i-1).group;
                            end
                        end
                    end
                    
                end

                stru.analysisInfo=analysis;

                % Part 3 - Select conditions items... We need to create and save several...
                for i=1:length(handles.selectconditions)
                    selconds(i).NumberOfConditions=handles.selectconditions(i).number;
                    selconds(i).Conditions=handles.selectconditions(i).index;
                    selconds(i).ConditionNames=handles.selectconditions(i).names;
                    selconds(i).Replicates=handles.selectconditions(i).repindex;
                    selconds(i).Exprp=handles.selectconditions(i).exprp;
                    selconds(i).hasRun=true;
                    selconds(i).prepro=true;
                end
                stru.selectedConditions=selconds;
                stru.selectConditionsIndex=length(handles.selectconditions)+1;

                % Part 4 - Project items... We need to create and save several...
                [pth,nam]=fileparts(handles.filename);
                project.Name=nam;
                project.Filename=handles.filename;
                project.Date=datestr(now);
                project.NumberOfConditions=handles.experimentInfo.numberOfConditions;

                count=0;
                index=0;
                for i=1:handles.experimentInfo.numberOfConditions
                    count=count+size(handles.experimentInfo.exprp{i},2);
                end
                project.NumberOfSlides=count;
                for i=1:handles.experimentInfo.numberOfConditions
                    for j=1:max(size(handles.experimentInfo.exprp{i}))
                        index=index+1;
                        streval=['project.Slides.',handles.experimentInfo.conditionNames{i},...
                                 '.','Slide',num2str(j),'=handles.experimentInfo.exprp{i}{j}',';'];
                        eval(streval)
                    end
                end
                
                % Background adjustment
                switch handles.backnormsum.backmethod
                    case 'rma'
                        backopts2text=['Truncate distribution : ',log2lang(handles.backnormsum.backopts.trunc)];
                    case 'gcrma'
                        bl1=['Optical correction : ',log2lang(handles.backnormsum.backopts.optcorr)];
                        bl2=['Gene specific binding correction : ',log2lang(handles.backnormsum.backopts.gsbcorr)];
                        bl3=['Add signal variance : ',log2lang(handles.backnormsum.backopts.addvar)];
                        bl4=['Correlation coefficient constant : ',num2str(handles.backnormsum.backopts.corrconst)];
                        bl5=['Signal estimation method : ',handles.backnormsum.backopts.method];
                        bl6=['Tuning parameter : ',num2str(handles.backnormsum.backopts.tuningpar)];
                        backopts2text=[bl1 ', ' bl2 ', ' bl3 ', ' bl4 ', ' bl5 ', ' bl6];
                    case 'plier'
                        % When we implement...
                    case 'none'
                        backopts2text=' ';
                end
                % Normalization
                switch handles.backnormsum.normmethod
                    case 'quantile'
                        normopts2text=['Use median : ',log2lang(handles.backnormsum.normopts.usemedian)];
                    case 'rankinvariant'
                        nl1=['Rank thresholds : ',num2str(handles.backnormsum.normopts.lowrank),' ',...
                                                  num2str(handles.backnormsum.normopts.uprank)];
                        nl2=['Higher or lower average rank exclusion position : ',...
                             num2str(handles.backnormsum.normopts.maxdata)];
                        nl3=['Maximum percentage of genes included in the rank invariant set : ',...
                             num2str(handles.backnormsum.normopts.maxinvar)];
                        nl4=['Data smoothing : ',handles.backnormsum.normopts.method];
                        nl5=['Span for data smoothing : ',num2str(handles.backnormsum.normopts.span)];
                        normopts2text=[nl1 ', ' nl2 ', ' nl3 ', ' nl4 ', ' nl5];
                    case 'none'
                        normopts2text=' ';
                end
                % Summarization
                switch handles.backnormsum.summmethod
                    case 'medianpolish'
                        summopts2text=['Output values : ',handles.backnormsum.summopts.output];
                    case 'mas5'
                        % When we implement...
                        summopts2text=' ';
                end
                % Filtering
                if ~handles.filtering.nofilt
                    if ~isempty(handles.filtering.alpha)
                        forp=['alpha : ',num2str(handles.filtering.alpha),', tau : ',num2str(handles.filtering.tau),...
                              ', limits : (',num2str(handles.filtering.alphalims(1)),...
                              ',',num2str(handles.filtering.alphalims(2)),')'];
                    else
                        forp='No';
                    end
                else
                    forp='No';
                end
                
                project.Analysis(1).Preprocess.BackgroundAdjustment=handles.backnormsum.backname;
                project.Analysis(1).Preprocess.BackgroundOptions=backopts2text;
                project.Analysis(1).Preprocess.Normalization=handles.backnormsum.normname;
                project.Analysis(1).Preprocess.NormalizationOptions=normopts2text;
                project.Analysis(1).Preprocess.Summarization=handles.backnormsum.summname;
                project.Analysis(1).Preprocess.SummarizationOptions=summopts2text;
                project.Analysis(1).Preprocess.MAS5Filter=forp;
                project.Analysis(1).Preprocess.IQRFilter=log2lang(handles.filtering.iqrv);
                project.Analysis(1).Preprocess.VarianceFilter=log2lang(handles.filtering.iqrv);
                project.Analysis(1).Preprocess.IntensityFilter=log2lang(handles.filtering.inten);
                project.Analysis(1).Preprocess.CustomFilter=log2lang(handles.filtering.custom);
                project.Analysis(1).Preprocess.OutlierTest=...
                    ['Outlier test : ',log2lang(handles.filtering.outlierTest),...
                    ' p-value : ',log2lang(handles.filtering.pvalue)];
                project.Analysis(1).StatisticalSelection=[];
                project.Analysis(1).Clustering=[];

                for i=2:length(handles.selectconditions)+1
                    
                    project.Analysis(i).Preprocess.BackgroundAdjustment=handles.backnormsum.backname;
                    project.Analysis(i).Preprocess.BackgroundOptions=backopts2text;
                    project.Analysis(i).Preprocess.Normalization=handles.backnormsum.normname;
                    project.Analysis(i).Preprocess.NormalizationOptions=normopts2text;
                    project.Analysis(i).Preprocess.Summarization=handles.backnormsum.summname;
                    project.Analysis(i).Preprocess.SummarizationOptions=summopts2text;
                    project.Analysis(i).Preprocess.MAS5Filter=forp;
                    project.Analysis(i).Preprocess.IQRFilter=log2lang(handles.filtering.iqrv);
                    project.Analysis(i).Preprocess.VarianceFilter=log2lang(handles.filtering.iqrv);
                    project.Analysis(i).Preprocess.IntensityFilter=log2lang(handles.filtering.inten);
                    project.Analysis(i).Preprocess.CustomFilter=log2lang(handles.filtering.custom);
                    project.Analysis(i).Preprocess.OutlierTest=...
                        ['Outlier test : ',log2lang(handles.filtering.outlierTest),...
                        ' p-value : ',log2lang(handles.filtering.pvalue)];

                    if isfield(handles,'results')
                        if isfield(handles.results,'DataCellFiltered') && ~isempty(handles.results(i-1).DataCellFiltered)
                            project.Analysis(i).StatisticalSelection.BSN=handles.statistics(i-1).scalename;
                            project.Analysis(i).StatisticalSelection.Impute=handles.statistics(i-1).imputename;
                            project.Analysis(i).StatisticalSelection.When=handles.statistics(i-1).imputebeforaftname;
                            project.Analysis(i).StatisticalSelection.TF=num2str(handles.statistics(i-1).tf);
                            project.Analysis(i).StatisticalSelection.Test=handles.statistics(i-1).stattestname;
                            project.Analysis(i).StatisticalSelection.Correction=handles.statistics(i-1).multicorrname;
                            project.Analysis(i).StatisticalSelection.Cut=num2str(handles.statistics(i-1).thecut);
                            if isfield(handles.results,'DataCellStat') && ~isempty(handles.results(i-1).DataCellStat)
                                project.Analysis(i).StatisticalSelection.DEGenes=...
                                    num2str(length(handles.results(i-1).DataCellStat{2}));
                            end
                        end
                        
                        if isfield(handles.results,'FinalTable') && ~isempty(handles.results(i-1).FinalTable)
                            project.Analysis(i).Clustering.Algorithm=handles.clustering(i-1).methodname;
                            switch(handles.clustering(i-1).method)
                                case 'hierarchical'
                                    lin=handles.clustering(i-1).linkage;
                                case 'kmeans'
                                    lin='None: using k-means clustering';
                                case 'fcm'
                                    lin='None: using FCM clustering';
                            end
                            project.Analysis(i).Clustering.Linkage=lin;
                            project.Analysis(i).Clustering.Distance=handles.clustering(i-1).distancename;
                            if isempty(handles.clustering(i-1).seed)
                                switch(handles.clustering(i-1).method)
                                    case 'hierarchical'
                                        se='None: using hierarchical clustering';
                                    case 'fcm'
                                        se='None: using FCM clustering';
                                end
                                project.Analysis(i).Clustering.Seed=se;
                            else
                                project.Analysis(i).Clustering.Seed=handles.clustering(i-1).seedname;
                            end
                            switch (handles.clustering(i-1).method)
                                case 'hierarchical'
                                    if isnan(handles.clustering(i-1).k)
                                        l2=num2str(handles.clustering(i-1).incutoff);
                                        l3=['Inconsistency : ',l2];
                                    elseif isnan(handles.clustering(i-1).incutoff)
                                        l2=num2str(handles.clustering(i-1).k);
                                        l3=['Maximum clusters : ',l2];
                                    end
                                    project.Analysis(i).Clustering.Limit=l3;
                                otherwise
                                    project.Analysis(i).Clustering.Limit=num2str(handles.clustering(i-1).k);
                            end
                            project.Analysis(i).Clustering.PValue=num2str(handles.clustering(i-1).pvalue);
                            project.Analysis(i).Clustering.Clusters=...
                                num2str(length(unique(handles.results(i-1).Clusters)));
                        end
                    end

                end

                stru.Project=project;

                % Save YFF

%                 hh=showinfowindow('Saving batch as ARMADA project. Please wait...','Saving');
                save(newfile,'stru')
%                 set(hh,'CloseRequestFcn','closereq')
%                 close(hh)
                
%             catch
%                 set(hh,'CloseRequestFcn','closereq')
%                 close(hh)
%                 errmsg={'An error occured while trying to save batch file',...
%                         newfile,...
%                         'as ARMADA project file.',...
%                         'Please make sure that you have run at least once your batch',...
%                         'procedure, review your settings or report the following error:',...
%                         lasterr};
%                 uiwait(errordlg(errmsg,'Error Saving Batch File'));
%             end
            
    end
    
end


function fileExit_Callback(hObject, eventdata, handles)

if handles.somethingChanged
    answer=questdlg('Do you want to save changes in your batch process?','Save changes');
    if strcmp(answer,'Yes')
        fileSave_Callback(hObject, eventdata, handles)
    elseif strcmp(answer,'No')
        uiresume(handles.BatchProgrammerAffy);
        delete(handles.BatchProgrammerAffy);
    elseif strcmp(answer,'Cancel')
        % Quietly do nothing
    end
else
    uiresume(handles.BatchProgrammerAffy);
    delete(handles.BatchProgrammerAffy);
end


function help_Callback(hObject, eventdata, handles)


function helpBatch_Callback(hObject, eventdata, handles)

msg={'Please consult ARMADA''s manual for help with the Batch Programmer.'};
uiwait(msgbox(msg,'Help','help'));


function helpAbout_Callback(hObject, eventdata, handles)

msg={'ARMADA Batch Programmer',...
     ' ',...
     'Metabolic Engineering and Bioinformatics Group',...
     'Institute of Biological Research and Biotechnology',...
     'National Hellenic Research Foundation',...
     ' ',...
     ' ',...
     'For information about this tool contact with:',...
     'Panagiotis Moulos (pmoulos@eie.gr)'};
uiwait(msgbox(msg,'About...','help'));


function backNormSumButton_Callback(hObject, eventdata, handles)

try
    
    % Get options
    count=0;
    arrays=cell(handles.Project.NumberOfSlides,1);
    for i=1:length(handles.experimentInfo.exprp)
        for j=1:length(handles.experimentInfo.exprp{i})
            count=count+1;
            arrays{count}=handles.experimentInfo.exprp{i}{j};
        end
    end
    [back,backName,backopts,norm,normName,normopts,summ,summName,summopts,cancel]=...
        NormalizationEditorAffy(arrays);
    
    if ~cancel
        % Set the parameters that do not need further manipulation
        handles.backnormsum.backmethod=back;
        handles.backnormsum.backopts=backopts;
        handles.backnormsum.backname=backName;
        handles.backnormsum.normmethod=norm;
        handles.backnormsum.normopts=normopts;
        handles.backnormsum.normname=normName;
        handles.backnormsum.summmethod=summ;
        handles.backnormsum.summopts=summopts;
        handles.backnormsum.summname=summName;

        % Indicate that filtering set
        handles.sets.backnormsumSet=true;
        % Indicate that something changed
        handles.somethingChanged=true;
        % Enable Normalization button
        set(handles.filteringButton,'Enable','on')
        % Enable run button because we have set basic process to run
        set(handles.runButton,'Enable','on')
        guidata(hObject,handles);
    end
    
catch
    errmsg={'An unexpected error occured during process.',lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function filteringButton_Callback(hObject, eventdata, handles)

try
    
    % Get options
    [alpha,tau,alphalims,margasabs,iqrv,varv,inten,custom,nofilt,export,usewaitbar,...
     outlierTest,pval,dishis,cancel]=FilteringEditorAffy;
    
    if ~cancel
        % Set the parameters that do not need further manipulation
        handles.filtering.alpha=alpha;
        handles.filtering.tau=tau;
        handles.filtering.alphalims=alphalims;
        handles.filtering.margasabs=margasabs;
        handles.filtering.iqrv=iqrv;
        handles.filtering.varv=varv;
        handles.filtering.inten=inten;
        handles.filtering.custom=custom;
        handles.filtering.nofilt=nofilt;
        handles.filtering.export=export;
        handles.filtering.usewaitbar=usewaitbar;
        handles.filtering.outlierTest=outlierTest;
        handles.filtering.pvalue=pval;
        handles.filtering.dishis=dishis;
        % Indicate that filtering set
        handles.sets.filterSet=true;
        % Indicate that something changed
        handles.somethingChanged=true;
        % Enable Normalization button
        set(handles.selCondButton,'Enable','on')
        % Enable run button because we have set basic process to run
        set(handles.runButton,'Enable','on')
        guidata(hObject,handles);
    end
    
catch
    errmsg={'An unexpected error occured during process.',lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function selCondButton_Callback(hObject, eventdata, handles)

try
    
    [repeat,newcondNumber,newcondIndex,newcondNames,newRepIndex,newExprp,cancel]=...
        SelectConditionsEditor(handles.experimentInfo.conditionNames,...
                               handles.experimentInfo.exprp,false);
                
    if ~cancel
        
        % Update indexing variable of the GUI
        handles.analysisIndex=handles.analysisIndex+1;
        ind=handles.analysisIndex;
        
        % Start creating new objects to analyze
        handles.selectconditions(ind).number=newcondNumber;
        handles.selectconditions(ind).index=newcondIndex;
        handles.selectconditions(ind).names=newcondNames;
        handles.selectconditions(ind).repindex=newRepIndex;
        handles.selectconditions(ind).exprp=newExprp;
        
        % Indicate select conditions run
        handles.sets.selcondSet=true;
        % Indicate that something changed
        handles.somethingChanged=true;
        % Enable Statistical Selection button
        set(handles.statButton,'Enable','on')
        
        % Update the analysis object listbox
        str=get(handles.analysisList,'String');
        str=[str;['Analysis ',num2str(ind)]];
        set(handles.analysisList,'String',str,'Value',ind);
        
        % Activate analysis list context menu
        set(handles.listContextView,'Enable','on')
        set(handles.listContextDelete,'Enable','on')
        
        guidata(hObject,handles);
    
    end
    
catch
    errmsg={'An unexpected error occured during process.',lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function statButton_Callback(hObject, eventdata, handles)

% Prepare the input variable to StatisticalSelectionBatchEditor
noanalysis=length(handles.selectconditions);
condind=zeros(1,noanalysis);
for i=1:noanalysis
    condind(i)=handles.selectconditions(i).number;
end
noarr=zeros(1,noanalysis);
for i=1:noanalysis
    count=0;
    for j=1:handles.selectconditions(i).number
        count=count+size(handles.selectconditions(i).exprp{j},2);
    end
    noarr(i)=count;
end
condnames=cell(1,noanalysis);
for i=1:noanalysis
    condnames{i}=handles.selectconditions(i).names;
end

try
    
    [scale,scaleOpts,scaleName,impute,imputeOpts,imputeName,...
     imputeBefOrAft,imputeBefOrAftName,statTest,statTestName,...
     multiCorr,multiCorrName,thecut,tf,stf,controlIndices,treatedIndices,...
     cancel]=StatisticalSelectionBatchEditor(noanalysis,condind,noarr,condnames,...
                                             handles.experimentInfo.imgsw);
        
    if ~cancel
        
        for i=1:noanalysis
            handles.statistics(i).scale=scale{i};
            handles.statistics(i).scaleopts=scaleOpts{i};
            handles.statistics(i).scalename=scaleName{i};
            handles.statistics(i).impute=impute{i};
            handles.statistics(i).imputeopts=imputeOpts{i};
            handles.statistics(i).imputename=imputeName{i};
            handles.statistics(i).imputebeforaft=imputeBefOrAft(i);
            handles.statistics(i).imputebeforaftname=imputeBefOrAftName{i};
            handles.statistics(i).stattest=statTest(i);
            handles.statistics(i).stattestname=statTestName{i};
            handles.statistics(i).multicorr=multiCorr(i);
            handles.statistics(i).multicorrname=multiCorrName{i};
            handles.statistics(i).thecut=thecut(i);
            handles.statistics(i).tf=tf(i);
            handles.statistics(i).stf=stf(i);
            handles.statistics(i).controlindices=controlIndices{i};
            handles.statistics(i).treatedindices=treatedIndices{i};
        end
        
        % Indicate select conditions run
        handles.sets.statSet=true;
        % Indicate that something changed
        handles.somethingChanged=true;
        % Enable Statistical Selection button
        set(handles.clusterButton,'Enable','on')
        
        guidata(hObject,handles);
        
    end

catch
    errmsg={'An unexpected error occured during process.',lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function clusterButton_Callback(hObject, eventdata, handles)

% Find the number of slides for this analysis (in order to place a limit for k in case
% user wants to cluster conditions
n=length(handles.selectconditions);
maxrep=zeros(1,n);
for i=1:n
    for j=1:handles.selectconditions(i).number
        maxrep(i)=maxrep(i)+max(size(handles.selectconditions(i).exprp{j}));
    end
end

try
    
    [method,methodname,repchoice,dim,linkage,distance,distancename,k,pvalue,...
     incutoff,disheat,colormap,cmapdensity,title,seed,seedname,repeat,maxiter,...
     fuzzyparam,tolerance,optimize,cvconstant,fuzzytolerance,fuzzyiter,cancel]=...
        ClusteringBatchEditor(n,maxrep);
    
    if ~cancel
        
        for i=1:n
            handles.clustering(i).method=method{i};
            handles.clustering(i).methodname=methodname{i};
            handles.clustering(i).repchoice=repchoice{i};
            handles.clustering(i).dim=dim(i);
            handles.clustering(i).linkage=linkage{i};
            handles.clustering(i).distance=distance{i};
            handles.clustering(i).distancename=distancename{i};
            handles.clustering(i).k=k(i);
            handles.clustering(i).pvalue=pvalue(i);
            handles.clustering(i).incutoff=incutoff(i);
            handles.clustering(i).disheat=disheat(i);
            handles.clustering(i).colormap=colormap{i};
            handles.clustering(i).cmapdensity=cmapdensity(i);
            handles.clustering(i).title=title{i};
            handles.clustering(i).seed=seed{i};
            handles.clustering(i).seedname=seedname{i};
            handles.clustering(i).repeat=repeat(i);
            handles.clustering(i).maxiter=maxiter(i);
            handles.clustering(i).fuzzyparam=fuzzyparam(i);
            handles.clustering(i).tolerance=tolerance(i);
            handles.clustering(i).optimize=optimize(i);
            handles.clustering(i).cvconstant=cvconstant(i);
            handles.clustering(i).fuzzytolerance=fuzzytolerance(i);
            handles.clustering(i).fuzzyiter=fuzzyiter(i);
        end
        
        % Indicate select conditions run
        handles.sets.clusterSet=true;
        % Indicate that something changed
        handles.somethingChanged=true;
        
        guidata(hObject,handles);
        
    end
   
catch
    errmsg={'An unexpected error occured during process.',lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function analysisList_Callback(hObject, eventdata, handles)

handles.currentIndex=get(hObject,'Value');
guidata(hObject,handles);


function analysisList_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function listContext_Callback(hObject, eventdata, handles)


function listContextView_Callback(hObject, eventdata, handles)

ind=handles.currentIndex;
if isfield(handles,'backnormsum')
    bns=handles.backnormsum;
else
    bns=[];
end
if isfield(handles,'filtering')
    filter=handles.filtering;
else
    filter=[];
end
if isfield(handles,'selectconditions') && length(handles.selectconditions)>=ind
    selcond=handles.selectconditions(ind);
else
    selcond=[];
end
if isfield(handles,'statistics') && length(handles.statistics)>=ind
    stats=handles.statistics(ind);
else
    stats=[];
end
if isfield(handles,'clustering') && length(handles.clustering)>=ind
    clus=handles.clustering(ind);
else
    clus=[];
end

AnalysisViewAffy(ind,bns,filter,selcond,stats,clus);


function listContextDelete_Callback(hObject, eventdata, handles)

% Get the index of the analysis to be deleted
ind=handles.currentIndex;

% Do the job...
if ind<=length(handles.selectconditions)
    handles.selectconditions(ind)=[];
end
if ind<=length(handles.statistics)
    handles.statistics(ind)=[];
end
if ind<=length(handles.clustering)
    handles.clustering(ind)=[];
end
handles.analysisIndex=handles.analysisIndex-1;

% Adjust the listbox value in case we delete the last analysis
if ind==get(handles.analysisList,'Value')
    set(handles.analysisList,'Value',ind-1)
end

% Check if we have deleted everything so as to maintain the list
if isempty(handles.selectconditions)
    set(handles.analysisList,'String','','Value',[])
    set(handles.statsButton,'Enable','off')
    set(handles.clusterButton,'Enable','off')
    set(handles.listContextView,'Enable','off')
    set(handles.listContextDelete,'Enable','off')
else % Update the analysis object list
    anal=cell(length(handles.selectconditions),1);
    for i=1:length(handles.selectconditions)
        anal{i}=['Analysis ',num2str(i)];
    end
    set(handles.analysisList,'String',anal)
    set(handles.listContextDelete,'Enable','on')
    set(handles.listContextView,'Enable','on')
end

% Adjust the listbox value in case we delete the first analysis
if ind==1
    set(handles.analysisList,'Value',1)
end

% Update the current selection too
handles.currentIndex=get(handles.analysisList,'Value');

% Refresh current selection index
handles.currentIndex=get(handles.analysisList,'Value');

% Indicate that something changed
handles.somethingChanged=true;

guidata(hObject,handles);


function runButton_Callback(hObject, eventdata, handles)

try
    
    intime=cputime;
    
    % Some funcy stuff
    disp('=====================================================================')
    disp('|                                                                   |')
    disp('|                             A R M A D A                           |')
    disp('|                                                                   |')
    disp('|             Automated Robust MicroArray Data Analysis             |')
    disp('|                                                                   |')
    disp('|                    Batch File Programming Module                  |')
    disp('|                                                                   |')
    disp('=====================================================================')
    disp(' ')

    % Begin process

    % Background adjustment
    handles.exptab=AffyBackAdjust(handles.datstruct,handles.cdfstruct,...
                                  handles.backnormsum.backmethod,...
                                  handles.backnormsum.backopts);
                              
    % Normalization
    handles.exptab=AffyNorm(handles.exptab,handles.backnormsum.normmethod,...
                                           handles.backnormsum.normopts);
                                       
    % Summarization
    [handles.DataCellNormLo,handles.gnID]=...
        AffySum(handles.exptab,handles.cdfstruct,...
                handles.backnormsum.summmethod,...
                handles.backnormsum.summopts,...
                {handles.backnormsum.backmethod,handles.backnormsum.normmethod});
    
    % Filtering
    [handles.DataCellNormLo,handles.TotalBadpoints]=...
        FilterGenesAffy(handles.datstruct,handles.DataCellNormLo,handles.cdfstruct,...
                        'MAS5Calls',{handles.filtering.alpha,handles.filtering.tau,handles.filtering.alphalims},...
                        'MarginAsAbsent',handles.filtering.margasabs,...
                        'IQR',handles.filtering.iqrv,...
                        'Variance',handles.filtering.varv,...
                        'Intensity',handles.filtering.inten,...
                        'Custom',handles.filtering.custom,...
                        'RepTest',handles.filtering.outlierTest,...
                        'PVal',handles.filtering.pvalue,...
                        'ShowHist',handles.filtering.dishis,...
                        'Conditions',handles.experimentInfo.conditionNames,...
                        'UseWaitbar',handles.filtering.usewaitbar,...
                        'ExportFilt',false);

    % Begin statistical selection and clustering

    for i=1:length(handles.selectconditions)
        
        if ~isempty(handles.statistics)

            handles.results(i).DataCellNormLo=...
                SelectConditions(handles.DataCellNormLo,...
                                 handles.selectconditions(i).index,...
                                 handles.selectconditions(i).repindex);

            % Correct topts options structure defined before
            imputeopts=handles.statistics(i).imputeopts;
            if strcmp(handles.statistics(i).impute,'knn')
                imputeopts=rmfield(imputeopts,'distancename');
            end

            % Perform statistical selection

            % Filter replicates
            handles.results(i).DataCellFiltered=...
                FilterReplicatesB(handles.results(i).DataCellNormLo,...
                                 handles.selectconditions(i).number,...
                                 handles.gnID,...
                                 'BetweenNorm',handles.statistics(i).scale,...
                                 'BetweenNormOpts',handles.statistics(i).scaleopts,...
                                 'Impute',handles.statistics(i).impute,...
                                 'ImputeOpts',imputeopts,...
                                 'ImputeWhen',handles.statistics(i).imputebeforaft,...
                                 'TrustFactor',handles.statistics(i).tf,...
                                 'StrictTF',handles.statistics(i).stf,...
                                 'ViewBoxplot',false,'HText',[]);

            % Statistical test
            if ~isempty(handles.results(i).DataCellFiltered)
                handles.results(i).DataCellStat=...
                    StatisticalTestB(handles.results(i).DataCellFiltered,...
                    handles.selectconditions(i).number,...
                    handles.selectconditions(i).names,...
                    handles.statistics(i).stattest,...
                    handles.statistics(i).multicorr,...
                    handles.statistics(i).thecut,[]);

                if ~isempty(handles.results(i).DataCellStat)
                    % Fold change calculation
                    m=length(handles.results(i).DataCellStat{2});
                    n=handles.selectconditions(i).number;
                    fcmat=zeros(m,n);
                    tind=handles.statistics(i).treatedindices;
                    cind=handles.statistics(i).controlindices;
                    % Values to calculate FC from
                    valuemat=handles.results(i).DataCellStat{1}(:,3:end);
                    % Calculate fold changes
                    for j=1:length(tind)
                        % Minus (-) ! We work on the log scale
                        fcmat(:,j)=valuemat(:,tind(j))-valuemat(:,cind(j));
                    end
                    handles.results(i).DataCellStat{9}=fcmat;
                end
            else
                mymessage(['No genes passed Trust Factor filtering step for Analysis run ',...
                          num2str(i),'. Statistical test will not be performed.'],[],1)
                handles.results(i).DataCellStat=[];
            end
            
        end

        % Clustering
        if ~isempty(handles.clustering)
            
            % Ensure that there are genes to cluster
            if ~isempty(handles.results(i).DataCellStat)
                
                try
            
                    switch handles.clustering(i).method

                        case 'hierarchical'

                            [handles.results(i).FinalTable,...
                                handles.results(i).Clusters,...
                                handles.results(i).PIndex,fig]=...
                                ExpHClustering(handles.results(i).DataCellStat,...
                                'ClusterWhat',handles.clustering(i).repchoice,...
                                'ClusterDim',handles.clustering(i).dim,...
                                'Distance',handles.clustering(i).distance,...
                                'Linkage',handles.clustering(i).linkage,...
                                'PValue',handles.clustering(i).pvalue,...
                                'Inconsistency',handles.clustering(i).incutoff,...
                                'MaxClust',handles.clustering(i).k,...
                                'DisplayHeatmap',handles.clustering(i).disheat,...
                                'Title',handles.clustering(i).title,'HText',[]);

                            % Set the proper colormap
                            if strcmpi(handles.clustering(i).colormap,'redgreen')
                                strcmap=['redgreencmap','(',num2str(handles.clustering(i).cmapdensity),')'];
                                colormap(strcmap)
                            elseif strcmpi(handles.clustering(i).colormap,'redgreenfixed')
                                % Load my adjusted fixed 64-colormap
                                S=load('MyColormaps','mycmap');
                                mycmap=S.mycmap;
                                set(fig,'Colormap',mycmap)
                            else
                                strcmap=[lower(handles.clustering(i).colormap),'(',...
                                    num2str(handles.clustering(i).cmapdensity),')'];
                                colormap(strcmap)
                            end
                            colorbar('OuterPosition',[0.9 -0.025 0.05 0.85],'FontSize',10);

                        case 'kmeans'

                            % Perform hierarchical clustering
                            [handles.results(i).FinalTable,...
                                handles.results(i).Clusters,...
                                handles.results(i).PIndex,...
                                handles.results(i).Centroids,...
                                sumofdists,singledists,...
                                handles.results(i).group]=...
                                kmeansClustering(handles.results(i).DataCellStat,...
                                handles.clustering(i).k,...
                                'ClusterWhat',handles.clustering(i).repchoice,...
                                'ClusterDim',handles.clustering(i).dim,...
                                'PValue',handles.clustering(i).pvalue,...
                                'Distance',handles.clustering(i).distance,...
                                'Start',handles.clustering(i).seed,...
                                'Replications',handles.clustering(i).repeat,...
                                'MaxIter',handles.clustering(i).maxiter,...
                                'EmptyAction','drop','Display','off','HText',[]);

                        case 'fcm'

                            [handles.results(i).FinalTable,...
                                handles.results(i).Clusters,...
                                handles.results(i).PIndex,...
                                handles.results(i).Centroids,...
                                u,handles.results(i).group]=...
                                FCMClustering(handles.results(i).DataCellStat,...
                                handles.clustering(i).k,...
                                'ClusterWhat',handles.clustering(i).repchoice,...
                                'ClusterDim',handles.clustering(i).dim,...
                                'PValue',handles.clustering(i).pvalue,...
                                'FuzzyParam',handles.clustering(i).fuzzyparam,...
                                'Tolerance',handles.clustering(i).tolerance,...
                                'MaxIter',handles.clustering(i).maxiter,...
                                'Optimize',handles.clustering(i).optimize,...
                                'CVThreshold',handles.clustering(i).cvconstant,...
                                'MTol',handles.clustering(i).fuzzytolerance,...
                                'OptMaxIter',handles.clustering(i).fuzzyiter,'HText',[]);

                    end
                
                catch
                    mymessage(lasterr,[],1)
                    continue
                end

            else
                mymessage(['No genes passed Statistical Selection for Analysis run ',...
                          num2str(i),'. Clustering will not be performed.'],[],1)
                handles.results(i).FinalTable=[];
            end
            
        end
        
    end
    
    guidata(hObject,handles);
    
    eltime=cputime-intime;
    
    if eltime<60
        elmsg=['Total process time : ',num2str(eltime,'%2.3f'),' seconds.'];
    else
        elinmin=eltime/60;
        elmsg=['Total process time : ',num2str(elinmin,'%15.3f'),' minutes.'];
    end
    
    disp(' ');
    disp('--------------------------------------------------')
    disp(elmsg);
    disp('--------------------------------------------------')
    disp(' ');
        
catch
    errmsg={'An unexpected error occured during the batch running process',...
            'process. Please review your settings and check your files.',...
            lasterr};
    uiwait(errordlg(errmsg,'Error'));
end


function closeButton_Callback(hObject, eventdata, handles)

fileExit_Callback(hObject,eventdata,handles);



%%%%%%%%%%%%%%%%%%% HELP FUNCTIONS %%%%%%%%%%%%%%%%%%%%

function stru = reinit(stru)

% Manage internal indicators
stru.analysisIndex=0;
stru.currentIndex=1;
stru.somethingChanged=false;

% Manage setting variables
stru.sets.backnormsumSet=false;
stru.sets.filterSet=false;
stru.sets.selcondSet=false;
stru.sets.statSet=false;
stru.sets.clusterSet=false; 

% Manage main batch programming structures
stru.backnormsum=[];
stru.filtering=[];
stru.selectconditions=[];
stru.statistics=[];
stru.clustering=[];

% Manage main list
set(stru.analysisList,'String','','Value',[])

% Manage buttons
set(stru.backNormSumButton,'Enable','off')
set(stru.filteringButton,'Enable','off')
set(stru.selCondButton,'Enable','off')
set(stru.statButton,'Enable','off')
set(stru.clusterButton,'Enable','off')
set(stru.runButton,'Enable','off')
