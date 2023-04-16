module Web.View.Tasks.Show where
import Web.View.Prelude

data ShowView = ShowView { task :: Task }

instance View ShowView where
    html ShowView { .. } = [hsx|
        {breadcrumb}
        <h1>Show Task</h1>
        <p>{task}</p>

    |]
        where
            breadcrumb = renderBreadcrumb
                            [ breadcrumbLink "Tasks" TasksAction
                            , breadcrumbText "Show Task"
                            ]