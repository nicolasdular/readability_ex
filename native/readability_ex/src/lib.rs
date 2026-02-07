use readabilityrs::{Readability, ReadabilityOptions};

#[global_allocator]
static GLOBAL: mimalloc::MiMalloc = mimalloc::MiMalloc;

#[rustler::nif(schedule = "DirtyCpu")]
fn extract_nif(html: String, url: Option<String>) -> Result<Option<String>, String> {
    let options = ReadabilityOptions::default();
    let readability =
        Readability::new(&html, url.as_deref(), Some(options)).map_err(|err| err.to_string())?;

    Ok(readability.parse().and_then(|article| article.content))
}

rustler::init!("Elixir.ReadabilityEx", [extract_nif]);
