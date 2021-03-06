function valid = checkmastruct(maStruct)
% CHECKMASTRUCT checks for standard mastruct types
%
% Currently supported: GenePix, Imagene, SPOT

% Copyright 2003-2005 The MathWorks, Inc.
% $Revision: 1.1.12.3 $   $Date: 2005/12/12 23:12:12 $
valid =  isfield(maStruct,'Header')&& isfield(maStruct.Header,'Type') && ...
        (~isempty(strfind(maStruct.Header.Type,'GenePix')) ...
        || ~isempty(strfind(maStruct.Header.Type,'FeatureExtractor'))...
        || ~isempty(strfind(maStruct.Header.Type,'SPOT'))...
        || ~isempty(strfind(maStruct.Header.Type,'ImaGene')));