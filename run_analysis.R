library(dplyr) # for left_join function

# Step 1: Merge the training and testing data.

# First read in the appropriate files.
# Data is separated into measurement identifiers,
# measurements, and subject identifiers. Bind training 
#vlabels and training measurements together using rbind.

# Getting and combining labels
train_labels <- read.table("train/y_train.txt")
test_labels <- read.table("test/y_test.txt")
acts <- rbind(train_labels,test_labels)

# Getting and combining measurements
train_feats <- read.table("train/x_train.txt")
test_feats <- read.table("test/x_test.txt")
feats <- rbind(train_feats,test_feats)

# Getting and combining subject IDss
train_subjects <- read.table("train/subject_train.txt")
test_subjects <- read.table("test/subject_test.txt")
subjects <- rbind(train_subjects,test_subjects)

# Step 2: Extract measurements that are averages or standard deviations.
# These include only mean() and std() variables, since the other instances
# of mean or standard deviation refer to the window length under which
# variables were recorded. There are 66 of these.


# Get the indeces corresponding to mean and std, as defined above.
feat_list <- read.table("features.txt")
feat_inds <- grep("*mean\\()|*std\\()",feat_list[,2])

# Use indeces to subset only relevant measurements.
rel_feats <- feats[,feat_inds]

# Step 3: Create meaningful names for each of the
# six activites.

# Names already exist, so first get these.
act_names <- read.table("activity_labels.txt")

# Change the activities to the new names and remove
# the column with numbered activity IDs.
new_acts <- left_join(acts,act_names,by='V1')
new_acts <- select(new_acts,V2)

# Step 4: Create meaningful variable names for the
# 66 relevant features. To do this, index the list
# of feature identifiers and use these to change
# the names of the measurements data frame.

# First combine everything into one final df,
# then change the column names.
combined <- cbind(subjects,new_acts,rel_feats)
rel_feat_names <- feat_list[feat_inds,]
names(combined) <- c("Subject","Activity",as.character(rel_feat_names$V2))

# Step 5: Create a new and tidy dataset with the
# means of each feature for each activity.

# Group by subject and activity, then use summarize function
# to summarize the other variables by those.
tidy_df <-
        combined %>%
        group_by(Subject,Activity) %>%
        summarize_all(mean)

# Save the data set.
write.table(tidy_df,"dataset.txt",row.name=FALSE)