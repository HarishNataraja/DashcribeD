-- queries table
CREATE TABLE IF NOT EXISTS queries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT,
  user_id TEXT,
  question TEXT,
  sql TEXT,
  explanation TEXT,
  safety_score DOUBLE PRECISION,
  cost_estimate JSONB,
  prompt_hash TEXT,
  llm_model TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS query_runs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  query_id UUID REFERENCES queries(id),
  run_type TEXT, -- simulate|execute
  status TEXT,
  runtime_ms INT,
  sample_ref TEXT,
  query_plan TEXT,
  tokens JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS presentations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT,
  user_id TEXT,
  outline JSONB,
  slides JSONB,
  s3_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS rootcauses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id TEXT,
  user_id TEXT,
  insight JSONB,
  hypotheses JSONB,
  created_at TIMESTAMPTZ DEFAULT now()
);