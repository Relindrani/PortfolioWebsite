pub fn evaluate(signal_type: &str, value: f64) -> &'static str {
    if signal_type == "temperature" && value > 80.0 {
        "ALERT"
    } else {
        "NORMAL"
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn high_temp_alert() {
        assert_eq!(evaluate("temperature", 90.0), "ALERT");
    }

    #[test]
    fn normal_temp() {
        assert_eq!(evaluate("temperature", 70.0), "NORMAL");
    }
}
