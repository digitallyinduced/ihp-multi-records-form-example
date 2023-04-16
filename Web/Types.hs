module Web.Types where

import IHP.Prelude
import IHP.ModelSupport
import Generated.Types

data WebApplication = WebApplication deriving (Eq, Show)


data StaticController = WelcomeAction deriving (Eq, Show, Data)

data TasksController
    = TasksAction
    | NewTaskAction
    | ShowTaskAction { taskId :: !(Id Task) }
    | CreateTaskAction
    | EditTaskAction { taskId :: !(Id Task) }
    | UpdateTaskAction { taskId :: !(Id Task) }
    | DeleteTaskAction { taskId :: !(Id Task) }
    deriving (Eq, Show, Data)
