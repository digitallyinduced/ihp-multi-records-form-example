module Web.Controller.Tasks where

import Web.Controller.Prelude
import Web.View.Tasks.Index
import Web.View.Tasks.New
import Web.View.Tasks.Edit
import Web.View.Tasks.Show

instance Controller TasksController where
    action TasksAction = do
        tasks <- query @Task |> fetch
        render IndexView { .. }

    action NewTaskAction = do
        let task = newRecord
        render NewView { .. }

    action ShowTaskAction { taskId } = do
        task <- fetch taskId
        render ShowView { .. }

    action EditTaskAction { taskId } = do
        task <- fetch taskId
        render EditView { .. }

    action UpdateTaskAction { taskId } = do
        task <- fetch taskId
        task
            |> buildTask
            |> ifValid \case
                Left task -> render EditView { .. }
                Right task -> do
                    task <- task |> updateRecord
                    setSuccessMessage "Task updated"
                    redirectTo EditTaskAction { .. }

    action CreateTaskAction = do
        let task = newRecord @Task
        task
            |> buildTask
            |> ifValid \case
                Left task -> render NewView { .. } 
                Right task -> do
                    task <- task |> createRecord
                    setSuccessMessage "Task created"
                    redirectTo TasksAction

    action DeleteTaskAction { taskId } = do
        task <- fetch taskId
        deleteRecord task
        setSuccessMessage "Task deleted"
        redirectTo TasksAction

buildTask task = task
    |> fill @'["description"]
