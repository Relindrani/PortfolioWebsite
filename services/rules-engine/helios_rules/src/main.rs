use helios_rules::{SignalDecisionInput, evaluate_signal};

fn main() {
    let Some(input_json) = std::env::args().nth(1) else {
        eprintln!("usage: helios_rules '<decision-input-json>'");
        std::process::exit(2);
    };

    let input: SignalDecisionInput = match serde_json::from_str(&input_json) {
        Ok(input) => input,
        Err(error) => {
            eprintln!("invalid decision input: {error}");
            std::process::exit(2);
        }
    };

    let decision = evaluate_signal(&input);
    match serde_json::to_string(&decision) {
        Ok(output) => println!("{output}"),
        Err(error) => {
            eprintln!("serialize decision: {error}");
            std::process::exit(1);
        }
    }
}
