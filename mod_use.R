mod_use_UI <- function(id) {
    ns <- NS(id)
    tagList(
        card(
            includeMarkdown(
                "www/md/use.md"
            )
        )
        
        # faq(data = df_FAQ, elementId = "faq", 
        #     expand_all_button_text = "Click here to expand all questions",
        #     collapse_all_button_text = "Collapse All",
        #     faqtitle = "Frequently Asked Questions",
        #     width ="100%")
    )
}

mod_use_Server <- function(id) {
    moduleServer(
        id,
        function(input, output, session) {
            
        }
    )
}