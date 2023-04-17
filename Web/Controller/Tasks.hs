module Web.Controller.Tasks where

import Web.Controller.Prelude
import Web.View.Tasks.Index
import Web.View.Tasks.New
import Web.View.Tasks.Edit
import Web.View.Tasks.Show

instance Controller TasksController where
    action TasksAction = do
        tasks <- query @Task |> fetch
                >>= collectionFetchRelated #tags
        render IndexView { .. }

    action NewTaskAction = do
        let tags = [newRecord @Tag, newRecord @Tag]
        let task = newRecord @Task
                |> updateField @"tags" tags
        render NewView { .. }

    action ShowTaskAction { taskId } = do
        task <- fetch taskId
        render ShowView { .. }

    action EditTaskAction { taskId } = do
        task <- fetch taskId
                >>= fetchRelated #tags
        render EditView { .. }

    action UpdateTaskAction { taskId } = do
        task <- fetch taskId

        let tagIds :: [Id Tag] = paramList "tags_id"
        let tagNames :: [Text] = paramList "tags_name"
        let tagNumbers :: [Int] = paramList "tags_number"
        originalTags <- fetch tagIds
        let tags = zip3 tagIds tagNames tagNumbers
                |> map (\(id, name, number) -> originalTags
                    |> find (\tag -> tag.id == id)
                    |> fromMaybe (newRecord |> set #taskId task.id)
                    |> \tag -> buildTag tag name number
                )


        task
            |> buildTask
            |> updateField @"tags" tags
            |> bubbleValidationResult #tags
            |> ifValid \case
                Left task -> do
                    render EditView { task }
                Right task -> do
                    (task, tags) <- withTransaction do
                        task <- task
                                |> clearTags
                                |> updateRecord
                        tags <- mapM updateOrCreateRecord tags
                        pure (task, tags)

                    setSuccessMessage "Task updated"
                    redirectTo EditTaskAction { .. }

    action CreateTaskAction = do
        let task = newRecord @Task
        let names :: [Text] = paramList "tags_name"
        let numbers :: [Int] = paramList "tags_number"
        let tags = zip names numbers |> map (\(name, number) -> buildTag newRecord name number)

        task
            |> buildTask
            |> updateField @"tags" tags
            |> bubbleValidationResult #tags
            |> ifValid \case
                Left task -> render NewView { task }
                Right taskAndTags -> do
                    (task, tags) <- withTransaction do
                        task <- taskAndTags |> clearTags |> createRecord
                        tags <- taskAndTags.tags
                            |> map (set #taskId task.id)
                            |> createMany

                        pure (task, tags)

                    setSuccessMessage "Task and Tags created"
                    redirectTo TasksAction

    action DeleteTaskAction { taskId } = do
        task <- fetch taskId
        deleteRecord task
        setSuccessMessage "Task deleted"
        redirectTo TasksAction

buildTask task = task
    |> fill @'["description"]
    |> validateField #description nonEmpty

buildTag :: Tag -> Text -> Int -> Tag
buildTag tag name number = tag
    |> set #name name
    |> set #number number
    |> validateField #name nonEmpty
    -- Validate number is above 10
    |> validateField #number (isGreaterThan 10)

-- | Adds a validation error to the record when any of the child records is invalid
bubbleValidationResult :: forall fieldName record childRecord.
    ( HasField "meta" record MetaBag
    , SetField "meta" record MetaBag
    , KnownSymbol fieldName
    , HasField fieldName record [childRecord]
    , HasField "meta" childRecord MetaBag
    , SetField "meta" childRecord MetaBag
    ) => Proxy fieldName -> record -> record
bubbleValidationResult field record =
        if isEmpty childAnnotations
            then record
            else record |> attachFailure field "Invalid records"
    where
        childAnnotations :: [(Text, Violation)]
        childAnnotations = get field record
            |> map (\record -> record.meta.annotations)
            |> concat

updateOrCreateRecord record | isNew record = createRecord record
updateOrCreateRecord record = updateRecord record

clearTags :: Include "tags" Task -> Task
clearTags task = updateField @"tags" (newRecord @Task).tags task