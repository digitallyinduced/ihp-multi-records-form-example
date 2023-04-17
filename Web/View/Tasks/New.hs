module Web.View.Tasks.New where
import Web.View.Prelude
import Text.Blaze.Html.Renderer.Text

data NewView = NewView { task :: Include "tags" Task }

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
renderForm :: Include "tags" Task -> Html
renderForm task = formFor task [hsx|
    {textField #description}

    <fieldset>
        <legend>Tags</legend>

        {nestedFormFor #tags renderTagForm}
    </fieldset>

    <button type="button" class="btn btn-light" data-prototype={prototypeFor #tags (newRecord @Tag)} onclick="this.insertAdjacentHTML('beforebegin', this.dataset.prototype)">Add Tag</button>

    {submitButton}
|]

prototypeFor :: _ => _ -> _ -> Text
prototypeFor field record =
        cs $ renderHtml prototype
    where
        parentFormContext = ?formContext
        prototype :: Html
        prototype = let ?formContext = parentFormContext { model = parentFormContext.model |> set field [newRecord] } in nestedFormFor field renderTagForm

renderTagForm :: (?formContext :: FormContext Tag) => Html
renderTagForm = [hsx|
    <fieldset class="border p-2 my-4">
        {(textField #name) { disableLabel = True, placeholder = "Tag name" } }
        {(numberField #number) { disableLabel = True, placeholder = "Tag number" } }
    </fieldset>
|]