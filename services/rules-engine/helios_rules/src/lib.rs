use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct SignalDecisionInput {
    pub event_id: String,
    pub signal_type: String,
    pub source: String,
    pub subject: String,
    pub correlation_id: String,
    pub payload: Option<String>,
}

#[derive(Debug, Serialize, PartialEq)]
#[serde(rename_all = "camelCase")]
pub struct SignalDecision {
    pub decision: String,
    pub outcome: String,
    pub confidence: f64,
    pub reasons: Vec<String>,
}

pub fn evaluate_signal(input: &SignalDecisionInput) -> SignalDecision {
    if input.signal_type.trim().is_empty() {
        return SignalDecision {
            decision: "RejectSignal".to_string(),
            outcome: "Rejected".to_string(),
            confidence: 1.0,
            reasons: vec!["Signal type is required for deterministic evaluation.".to_string()],
        };
    }

    match input.signal_type.as_str() {
        "ProvisioningRequested" => SignalDecision {
            decision: "StartProvisioningWorkflow".to_string(),
            outcome: "WorkflowRequired".to_string(),
            confidence: 1.0,
            reasons: vec![
                "Provisioning requests require explicit workflow orchestration.".to_string(),
                "Long-running work is not executed in the API request path.".to_string(),
            ],
        },
        "PortfolioViewed" | "DurableSignalSmokeTest" | "GoProcessorSmokeTest" => SignalDecision {
            decision: "NoActionRequired".to_string(),
            outcome: "Observed".to_string(),
            confidence: 1.0,
            reasons: vec!["Signal is observational and does not require a workflow.".to_string()],
        },
        _ => SignalDecision {
            decision: "RecordForReview".to_string(),
            outcome: "NeedsReview".to_string(),
            confidence: 1.0,
            reasons: vec![
                "No deterministic rule is registered for this signal type.".to_string(),
                "The signal remains recorded as a canonical fact for operator review.".to_string(),
            ],
        },
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn provisioning_request_starts_workflow() {
        let decision = evaluate_signal(&input("ProvisioningRequested"));

        assert_eq!(decision.decision, "StartProvisioningWorkflow");
        assert_eq!(decision.outcome, "WorkflowRequired");
    }

    #[test]
    fn portfolio_view_is_observational() {
        let decision = evaluate_signal(&input("PortfolioViewed"));

        assert_eq!(decision.decision, "NoActionRequired");
        assert_eq!(decision.outcome, "Observed");
    }

    #[test]
    fn unknown_signal_requires_review() {
        let decision = evaluate_signal(&input("UnknownSignal"));

        assert_eq!(decision.decision, "RecordForReview");
        assert_eq!(decision.outcome, "NeedsReview");
    }

    fn input(signal_type: &str) -> SignalDecisionInput {
        SignalDecisionInput {
            event_id: "evt_test".to_string(),
            signal_type: signal_type.to_string(),
            source: "test".to_string(),
            subject: "subject".to_string(),
            correlation_id: "correlation".to_string(),
            payload: None,
        }
    }
}
