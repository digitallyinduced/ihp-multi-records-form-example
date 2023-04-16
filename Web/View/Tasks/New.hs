module Web.View.Tasks.New where
import Web.View.Prelude

data NewView = NewView { task :: Task }

instance View NewView where
    html NewView { .. } = [hsx|
        {breadcrumb}
        <h1>New Task</h1>
        {renderForm task}
    |]
        where
            breadcrumb = renderBreadcrumb
                [ breadcrumbLink "Tasks" TasksAction
                , breadcrumbText "New Task"
                ]

renderForm :: Task -> Html
renderForm task = formFor task [hsx|
    {(textField #description)}
    {submitButton}

|]