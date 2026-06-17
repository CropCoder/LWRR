person <- function(name, title, company) {
    div(
        class = "person",
        h3(class = "name", name),
        div(class = "title", title),
        div(class = "company", company)
    )
}
