module Web.View.Tasks.Index where
import Web.View.Prelude

data IndexView = IndexView { tasks :: [Include "tags" Task]  }

instance View IndexView where
    html IndexView { .. } = [hsx|
        <h1>Tasks<a href={pathTo NewTaskAction} class="btn btn-primary ms-4">+ New</a></h1>
        <div class="table-responsive">
            <table class="table">
                <thead>
                    <tr>
                        <th>Task</th>
                        <th></th>
                        <th></th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>{forEach tasks renderTask}</tbody>
            </table>
            
        </div>
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Tasks" TasksAction
                ]

renderTask :: Include "tags" Task -> Html
renderTask task = [hsx|
    <tr>
        <td>{task.description}</td>
        <td>{renderTags task.tags}</td>
        <td><a href={ShowTaskAction task.id}>Show</a></td>
        <td><a href={EditTaskAction task.id} class="text-muted">Edit</a></td>
        <td><a href={DeleteTaskAction task.id} class="js-delete text-muted">Delete</a></td>
    </tr>
|]

renderTags :: [Tag] -> Text
renderTags tags =
    tags
    |> map (.name)
    |> intercalate ", "