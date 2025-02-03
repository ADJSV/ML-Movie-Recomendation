%Angel Salges
%Project ML Analysis
%%
format short g
data = readtable('dftocsv.csv');


%%
%Find duplicates
% Find unique rows
[~, ia, ic] = unique(data, 'rows');

% Identify duplicates
duplicates = data(~ismember(1:height(data), ia), :);

disp('Duplicate rows:');
disp(duplicates);

% Find duplicates in 'ID' column
[~, idx] = unique(data, 'rows');
dupRows = setdiff(1:height(data), idx);
disp('Duplicate columns:');
duplicates = data(dupRows, :);
disp(duplicates);
%%
%Remove users with <50 reviews 
T=data;
userCounts = groupcounts(T, 'userId'); % Counts how many rows each UserID has
usersToKeep = userCounts.userId(userCounts.GroupCount >= 50); % UserIDs with >= 50 reviews
filteredTable = T(ismember(T.userId, usersToKeep), :);
%%

%Rating analysis
ratingCounts = groupcounts(filteredTable, 'rating'); % Group by 'Rating'

disp('Distribution of Ratings:');
disp(ratingCounts);

% Bar graph
figure;
bar(ratingCounts.rating, ratingCounts.GroupCount, 'FaceColor', [0.2, 0.6, 0.8]);
hold on;

% Add counts on top of each bar
for i = 1:height(ratingCounts)
    text(ratingCounts.rating(i), ratingCounts.GroupCount(i) + 1000, ...
        num2str(ratingCounts.GroupCount(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% Adjust x-axis to have labels with 0.5 increments
xticks(min(ratingCounts.rating):0.5:max(ratingCounts.rating));

% Labels and title
xlabel('Rating');
ylabel('Count');
title('Distribution of Ratings');
grid on;
%%
%Genres Analysis
%Genre read. only do once takes a long time

% expandedGenres = cellfun(@(x) strsplit(x, '|'), filteredTable.genres, 'UniformOutput', false);
% temp=filteredTable(:,4);
% temp=table2cell(temp);
% temp2=[];
% flattenedGenres=[];
% for i = 1:length(expandedGenres)
%     for j=1:length(expandedGenres{i})
%     flattenedGenres = [flattenedGenres; expandedGenres{i}(:,j)];  % Concatenate each genre list
%     temp2 = [temp2;temp(i,:)];
%     end
% end

[uniqueGenres, ~, genreIdx] = unique(flattenedGenres(:,1));  % Get unique genres and their indices
genreCounts = histcounts(genreIdx, 1:numel(uniqueGenres) + 1);
genreTable = table(uniqueGenres, genreCounts');
[~, sortedIndices] = sort(genreTable.Var2, 'descend');
topGenres = genreTable(sortedIndices(1:min(5, end)), :);  % Select top 5 genres
figure;
% Bar graph 
bar(1:height(genreTable), genreTable.Var2, 'FaceColor', [0.2, 0.6, 0.8], 'BarWidth', 0.7);


% Add counts on top of each bar with a higher offset
for i = 1:height(genreTable)
    text(i, genreTable.Var2(i) + 500, ...
        num2str(genreTable.Var2(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% Adjust x-axis labels to display genre names
xticks(1:height(genreTable));
xticklabels(genreTable.uniqueGenres);
xtickangle(45); % Rotate labels for better readability

% Labels and title
xlabel('Genre');
ylabel('Count');
title('Distribution of Genres');
grid on;

disp('Top 5 Genres:');
disp(topGenres);
%%
expandedRatings=cell2mat(temp2);
genreRatingTable = table(categorical(flattenedGenres), expandedRatings);

%average rating for each genre
avgRatingPerGenre = varfun(@mean, genreRatingTable, 'InputVariables', 'expandedRatings', 'GroupingVariables', 'Var1');

% genre with the highest average rating
[~, idx] = max(avgRatingPerGenre.mean_expandedRatings);  % Find the index of the highest average rating
topGenre = avgRatingPerGenre.Var1(idx);  % Get the genre with the highest average rating
topAvgRating = avgRatingPerGenre.mean_expandedRatings(idx);  % Get the top genre's average rating


figure;
bar(avgRatingPerGenre.mean_expandedRatings);
hold on;

for i = 1:length(avgRatingPerGenre.mean_expandedRatings)
    text(i, avgRatingPerGenre.mean_expandedRatings(i) + 0.1, ...
        num2str(avgRatingPerGenre.mean_expandedRatings(i), '%.2f'), ...
        'HorizontalAlignment', 'center', 'FontSize', 10);
end

xticks(1:length(avgRatingPerGenre.Var1));
xticklabels(avgRatingPerGenre.Var1);
xtickangle(45);


title('Average Rating per Genre');
xlabel('Genre');
ylabel('Average Rating');

highlight = find(strcmp(avgRatingPerGenre.Var1, topGenre));
bar(highlight, topAvgRating, 'FaceColor', [1 0 0]);  % Highlight the bar with a different color

grid on;

% Display 
disp(['The genre with the highest average rating is: ', topGenre]);
disp(['Its average rating is: ', num2str(topAvgRating)]);