module Web.View.Tasks.Edit where
import Web.View.Prelude

data EditView = EditView { task :: Task }

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

renderForm :: Task -> Html
renderForm task = formFor task [hsx|
    {(textField #description)}
    {submitButton}

|]