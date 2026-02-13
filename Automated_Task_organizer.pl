use strict;
use warnings;

# ===== Task Class Definition =====
{
    package Task;   # Define a package (like a class) called Task

   # Constructor to create a new Task object
    sub new {
        my ($class, %args) = @_;
        my $self = {
            title       => $args{title} || '',     # Task title
            description => $args{description} || '',  # Task description
            due_date    => $args{due_date} || '',    # Task due date
            priority    => $args{priority} || '',   # Task priority
        };
        bless $self, $class;
        return $self;    # Return the object
    }
 
   # Display the task details 
    sub display {
        my ($self, $index) = @_;
        print "$index. [$self->{priority}] $self->{title} (Due: $self->{due_date})\n";
        print "    Description: $self->{description}\n";
    }


   # Convert a Task object to a single line (for saving to file)
    sub to_text {
        my ($self) = @_;
        return <<"END";
Title: $self->{title}
Description: $self->{description}
Due Date: $self->{due_date}
Priority: $self->{priority}
---
END
   }

      # Create a Task object from a single line read from file
      sub from_text_block {
        my ($class, $text) = @_;
        my %fields;
        for my $line (split /\n/, $text) {
            if ($line =~ /^Title:\s*(.*)/) { $fields{title} = $1 }
            elsif ($line =~ /^Description:\s*(.*)/) { $fields{description} = $1 }
            elsif ($line =~ /^Due Date:\s*(.*)/) { $fields{due_date} = $1 }
            elsif ($line =~ /^Priority:\s*(.*)/) { $fields{priority} = $1 }
        }
        return $class->new(%fields);
    }
}

# ===== Main Program Starts Here =====

my $filename = "tasks.txt";  # File where tasks will be saved

my @tasks;   # Array to hold all tasks

# Load existing tasks if file exists
if (-e $filename) {
    open my $fh, '<', $filename or die "Cannot open $filename: $!";
    local $/ = undef;  # Read whole file
    my $content = <$fh>;
    close $fh;

    my @blocks = split /---\n/, $content;
    foreach my $block (@blocks) {
        next unless $block =~ /\S/;  # Skip empty blocks
        push @tasks, Task->from_text_block($block);  # Create Task objects from each line
    }
}

while (1) {
    print "\nTo-Do List Menu:\n";
    print "1. Add Task\n2. View Tasks\n3. Delete Task\n4. Save and Exit\n";
    print "Enter your choice: ";
    chomp(my $choice = <STDIN>);

    if ($choice == 1) {
    # Add a new task
        print "Enter Title: ";        chomp(my $title = <STDIN>);
        print "Enter Description: ";  chomp(my $desc  = <STDIN>);
        print "Enter Due Date (YYYY-MM-DD): "; chomp(my $date  = <STDIN>);
        print "Enter Priority (High/Medium/Low): "; chomp(my $prio  = <STDIN>);

        my $task = Task->new(
            title       => $title,
            description => $desc,
            due_date    => $date,
            priority    => ucfirst(lc($prio))  # Normalize priority (first letter capital)
        );

        push @tasks, $task;    # Add the new task to the task list
        print "Task added successfully.\n";

    } elsif ($choice == 2) {
     # View all tasks
        if (@tasks) {
            print "\nYour Tasks:\n";
            for my $i (0 .. $#tasks) {
                $tasks[$i]->display($i + 1);  # Display each task with its number
            }
        } else {
            print "No tasks available.\n";
        }

    } elsif ($choice == 3) {
        print "Enter the task number to delete: ";
        chomp(my $num = <STDIN>);
        if ($num > 0 && $num <= @tasks) {
            splice(@tasks, $num - 1, 1);
            print "Task deleted.\n";
        } else {
            print "Invalid task number.\n";
        }

    } elsif ($choice == 4) {
        # Sort tasks by Priority (High -> Medium -> Low)
        my %priority_order = (High => 1, Medium => 2, Low => 3);
        @tasks = sort {
            ($priority_order{$a->{priority}} <=> $priority_order{$b->{priority}})
                ||
            ($a->{due_date} cmp $b->{due_date})
        } @tasks;

        open my $fh, '>', $filename or die "Cannot open $filename: $!";
        foreach my $task (@tasks) {
            print $fh $task->to_text();
        }
        close $fh;
        print "Tasks saved to '$filename'. Exiting...\n";
        last;

    } else {
      # Invalid menu choice
        print "Invalid choice, try again.\n";
    }
}
