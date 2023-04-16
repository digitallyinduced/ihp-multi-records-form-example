module Web.View.Tasks.Edit where
import Web.View.Prelude
import Web.View.Tasks.New (renderForm)

data EditView = EditView { task :: Include "tags" Task }

instance View EditView where
    html EditView { .. } = [hsx|
        {breadcrumb}
        <h1>Edit Task</h1>
        {renderForm task}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Tasks" TasksAction
                , breadcrumbText "Edit Task"
                ]