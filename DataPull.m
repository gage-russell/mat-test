function [labSet, veraxSet] = DataPull(varargin)
%Arguments:
%	sites = cell array of strings (i.e. {'string1', 'string2'})
%       sites refers to the names of Verax systems (i.e. 'SGR', etc.)
%       for a list of options use listSites()
%
%	analysis_number = vector of integers (i.e. [1, 2, 3])
%       analysis numbers refer to the 1-10 number ID of Verax streams
%
%	status = cell array of strings (i.e. {'string1', 'string2'})
%       status options: 'processed', 'client processed', 'sampled'
%
%	container_type = cell array of strings (i.e. {'string1', 'string2'})
%       container options: 'water disp cylinder', 'piston', 'open bottle', 'gas cylinder'
%       for a list of options use listContainers()
%
%	lab_method = cell array of strings (i.e. {'string1', 'string2'})
%       for a list of options use listMethods()
%
%	phase = cell array of strings (i.e. {'string1', 'string2'})
%       'gas' or 'liquid' (both if not specified)
%
%	lab = cell array of strings (i.e. {'string1', 'string2'})
%       for a list of labs use listLabs()
%
%   analysis_type = cell array of strings (i.e. {'string1', 'string2'})
%       for a list of labs use listAnalysisTypes()
%
%   valid_bool = Y or N
%       Defaulted to "Y"
%
%   lib_bool = Y or N
%       Not yet intended for use
%
%   is_library_sample = Y or N
%       Not yet intended for use
%
%Syntax for input arguments: 
%DataPull('sites', {'...'}, 'analysis_number', ['...'], 'status', {'...'}, 'container_type', {'...'}, 'lab_method', {'...'}, 'phase', {'...'}, 'lab', {'...'})
%
%This function has (2) outputs: [labSet, veraxSet]:
%   veraxSet (dataset object) contains spectral data
%   labSet (dataset object) contains sample data
%
%Example DataPull call containing multiple inputs for all arguments:
%   [labSet, veraxSet]=DataPull('sites', {'sgr', 'jewell'},
%                   'analysis_number', [1,2], 'status', {'processed', 'client processed'},
%                   'container_type', {'piston', 'water disp cylinder'}, 'lab_method',{'gpa 2103', 'astm d6377'},
%                   'phase', {'liquid', 'gas'}, 'lab', {'SPL CO, Intertek Texas'})


    %Parse varargin
    [sample_filters, result_filters] = inputReader.read(varargin{:});
  
    %returns [(no. samples) x 1] struct array 
    samples = queryBuilder.paged_query('internal_data/getSamplesForModeling', sample_filters, 'get', 'JSON');
    disp("I made it past samples")

    %Clean the samples data (fill -99 on anything that is missing)
    samples = dataTransform.cleanSamples(samples);
    
    %Add sample_id's to result_filters
    result_filters.sample_id = [samples.sample_id];  
    %returns 1x1 struct with fields [columns, index, data]
    results = queryBuilder.result_query('internal_data/getSampleResultsForModeling', result_filters, 'post', 'JSON');
    disp("I made it past results")
    
    %Generate the labset for sample results
    [labSet, samples] = datasetBuilder.formatLabSet(samples, results);
    
    %Generate the labset for spectral results
    veraxSet = datasetBuilder.formatVeraxSet(samples, results);                        
    
end



