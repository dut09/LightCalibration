%   Tao Du
%   taodu@stanford.edu
%   May 31, 2014

%   reduce function
%   input: 
%       id: a nx1 index vector
%       data: a n x m matrix
%   output:
%       id: the unique, sorted id
%       data: for each column in data, sum up the entries that correspond
%       to the same index in id, and sort them based on id
%   example:
%       id = [3; 1; 1; 3; 2; 4; 4; 4]
%       data = [1; 2; 3; 4; 5; 6; 7; 8]
%   output:
%       id = [1; 2; 3; 4]
%       data = [5; 5; 5; 21]

function [ id, data ] = reduce_by_id( id, data )
    %   id = [3; 1; 1; 3; 2; 4; 4; 4]
    [id, perm] = sort(id);
    %   id = [1; 1; 2; 3; 3; 4; 4; 4]
    difference = diff([id; max(id) + 1]);
    %   difference = [0; 1; 1; 0; 1; 0; 0; 1];
    count = diff(find([1;difference]));
    %   find([1;difference]) = [1; 3; 4; 6; 9];
    %   count = [2; 1; 2; 3]
    %   the unique id
    id = id(logical(difference));
    %   id = [1; 2; 3; 4]
    
    %   process each column in data
    %   first, permutate in each column
    data = data(perm, :);
    %   data = [2; 3; 5; 1; 4; 6; 7; 8];
    %   compute the cumulative sum
    cum_data_sum = cumsum(data, 1);
    %   cum_data_sum = [2; 5; 10; 11; 15; 21; 28; 36];
    cum_data_sum = cum_data_sum(logical(difference), :);
    %   cum_data_sum = [5; 10; 15; 36]
    cum_data_sum = [zeros(1, size(cum_data_sum, 2)); cum_data_sum];
    %   cum_data_sum = [0; 5; 10; 15; 36];
    data = diff(cum_data_sum);
    %   data = [5; 5; 5; 21];
end

