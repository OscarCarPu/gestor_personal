# Database Design (DynamoDB)

### Storage Strategy
Calendar entries older than one month will be archived to S3 in JSON format, organized by year and month (e.g., `gestor_personal/calendar.json`).
This keeps the active DynamoDB table lean with only current and upcoming entries, while maintaining historical data in a cost-effective way.

### Single Table Design
- **PK: entity (String) [project, task, recado, calendar, event, tasktime]** *Entity type identifier for partitioning*
- **SK: id (Number)** *Auto-incrementing identifier for each entity type*

### Entity Types and Attributes

#### Project Entity (PK: "project")
- **SK: id** *Auto-incrementing project identifier*
- **name (String, required)** *Display name of the project*
- **description (String, optional, default: "")** *Detailed project description or overview*
- **status (String, required, default: "active") [active, archived, completed]** *Current state of the project lifecycle*
- **tags (List, optional, default: [])** *Keywords for project categorization and searching*
- **totalTimeSpent (Number, required, default: 0)** *Total minutes dedicated to this project*
- **creationDate (String, timestamp, required, auto-generated)** *When project was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*

#### Task Entity (PK: "task")
- **SK: id** *Auto-incrementing task identifier*
- **projectId (Number, required)** *Reference to parent project*
- **parentTaskId (Number, optional, default: null)** *Reference to parent task if this is a subtask*
- **title (String, required)** *Short task name/title for display*
- **description (String, optional, default: "")** *Detailed task description and requirements*
- **status (String, required, default: "new") [new, in_progress, pending, completed, regular]** *Current state of task completion, regular for routine tasks*
- **pendingReason (String, optional)** *Reason for pending status [waiting_for_task, waiting_for_recado, waiting_for_date, external]*
- **pendingTargetId (String, optional)** *ID and entity type of the pending target task or recado in format entity#id*
- **pendingDate (String, timestamp, optional)** *Target date when the pending status should be resolved*
- **pendingDescription (String, optional)** *Detailed description of why the task is pending and what needs to be resolved*
- **priority (String, required, default: "medium") [high, medium, low]** *Task importance level for sorting*
- **hasSubtasks (Boolean, required, default: false)** *Indicates if task has child tasks*
- **subtasksCount (Number, required, default: 0)** *Number of direct child tasks*
- **dependencies (List[Number], optional, default: [])** *List of task IDs that must be completed first*
- **dueDate (String, timestamp, optional)** *Deadline for task completion*
- **totalTimeSpent (Number, required, default: 0)** *Total minutes dedicated directly to this task*
- **totalTimeSpentWithChildren (Number, required, default: 0)** *Total minutes including all subtasks*
- **creationDate (String, timestamp, required, auto-generated)** *When task was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*

#### Recado Entity (PK: "recado")
- **SK: id** *Auto-incrementing recado identifier*
- **taskId (Number, required)** *Reference to the associated task*
- **title (String, required)** *Short note title for display*
- **description (String, optional, default: "")** *Main content of the note or reminder*
- **status (String, required, default: "pending") [pending, completed]** *Current state of the recado*
- **priority (String, required, default: "medium") [high, medium, low]** *Importance level for sorting*
- **scheduledDateTime (String, timestamp, optional)** *Specific date/time for appointments (e.g., dentist)*
- **creationDate (String, timestamp, required, auto-generated)** *When recado was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*

#### Event Entity (PK: "event")
- **SK: id** *Auto-incrementing event identifier*
- **title (String, required)** *Event name (e.g., Carnaval)*
- **description (String, optional, default: "")** *Event details*
- **taskId (Number, optional)** *Reference to the associated task*
- **location (String, optional)** *Where the event takes place*
- **notifyBefore (Number, optional)** *Minutes before to send notification*
- **creationDate (String, timestamp, required, auto-generated)** *When event was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*

#### Calendar Entry Entity (PK: "calendar")
- **SK: id** *Auto-incrementing calendar entry identifier*
- **entityType (String, required) [task, recado, event]** *Type of entity being scheduled*
- **entityId (Number, required)** *ID of the task, recado or event*
- **datetimeStart (String, timestamp, required)** *Start date and time*
- **datetimeEnd (String, timestamp, required)** *End date and time*
- **creationDate (String, timestamp, required, auto-generated)** *When calendar entry was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*

#### TaskTime Entity (PK: "tasktime")
- **SK: id** *Auto-incrementing time entry identifier*
- **taskId (Number, required)** *Reference to the task*
- **minutes (Number, required)** *Minutes spent on task*
- **datetimeStart (String, timestamp, required)** *Start date and time*
- **datetimeEnd (String, timestamp, required)** *End date and time*
- **description (String, optional)** *Notes about what was done*
- **creationDate (String, timestamp, required, auto-generated)** *When time entry was created*
- **updateDate (String, timestamp, required, auto-generated)** *Last modification timestamp*
