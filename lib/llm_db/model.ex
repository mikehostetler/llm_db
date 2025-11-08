defmodule LLMDb.Model do
  @moduledoc """
  Model struct with Zoi schema validation.

  Represents an LLM model with complete metadata including identity, provider,
  dates, limits, costs, modalities, capabilities, tags, deprecation status, and aliases.
  """

  @limits_schema Zoi.object(%{
                   context: Zoi.integer() |> Zoi.min(1) |> Zoi.optional(),
                   output: Zoi.integer() |> Zoi.min(1) |> Zoi.optional()
                 })

  @cost_schema Zoi.object(%{
                 input: Zoi.number() |> Zoi.optional(),
                 output: Zoi.number() |> Zoi.optional(),
                 request: Zoi.number() |> Zoi.optional(),
                 cache_read: Zoi.number() |> Zoi.optional(),
                 cache_write: Zoi.number() |> Zoi.optional(),
                 training: Zoi.number() |> Zoi.optional(),
                 image: Zoi.number() |> Zoi.optional(),
                 audio: Zoi.number() |> Zoi.optional()
               })

  @reasoning_schema Zoi.object(%{
                      enabled: Zoi.boolean() |> Zoi.optional(),
                      token_budget: Zoi.integer() |> Zoi.min(0) |> Zoi.optional()
                    })

  @tools_schema Zoi.object(%{
                  enabled: Zoi.boolean() |> Zoi.optional(),
                  streaming: Zoi.boolean() |> Zoi.optional(),
                  strict: Zoi.boolean() |> Zoi.optional(),
                  parallel: Zoi.boolean() |> Zoi.optional()
                })

  @json_schema Zoi.object(%{
                 native: Zoi.boolean() |> Zoi.optional(),
                 schema: Zoi.boolean() |> Zoi.optional(),
                 strict: Zoi.boolean() |> Zoi.optional()
               })

  @streaming_schema Zoi.object(%{
                      text: Zoi.boolean() |> Zoi.optional(),
                      tool_calls: Zoi.boolean() |> Zoi.optional()
                    })

  @embeddings_schema Zoi.object(%{
                       min_dimensions: Zoi.integer() |> Zoi.min(1) |> Zoi.optional(),
                       max_dimensions: Zoi.integer() |> Zoi.min(1) |> Zoi.optional(),
                       default_dimensions: Zoi.integer() |> Zoi.min(1) |> Zoi.optional()
                     })

  @capabilities_schema Zoi.object(%{
                         chat: Zoi.boolean() |> Zoi.default(true),
                         embeddings:
                           Zoi.union([Zoi.boolean(), @embeddings_schema]) |> Zoi.default(false),
                         reasoning: @reasoning_schema |> Zoi.default(%{enabled: false}),
                         tools:
                           @tools_schema
                           |> Zoi.default(%{
                             enabled: false,
                             streaming: false,
                             strict: false,
                             parallel: false
                           }),
                         json:
                           @json_schema
                           |> Zoi.default(%{native: false, schema: false, strict: false}),
                         streaming:
                           @streaming_schema |> Zoi.default(%{text: true, tool_calls: false})
                       })

  @schema Zoi.struct(
            __MODULE__,
            %{
              id: Zoi.string(),
              provider: Zoi.atom(),
              provider_model_id: Zoi.string() |> Zoi.optional(),
              name: Zoi.string() |> Zoi.optional(),
              family: Zoi.string() |> Zoi.optional(),
              release_date: Zoi.string() |> Zoi.optional(),
              last_updated: Zoi.string() |> Zoi.optional(),
              knowledge: Zoi.string() |> Zoi.optional(),
              limits: @limits_schema |> Zoi.optional(),
              cost: @cost_schema |> Zoi.optional(),
              modalities:
                Zoi.object(%{
                  input: Zoi.array(Zoi.atom()) |> Zoi.optional(),
                  output: Zoi.array(Zoi.atom()) |> Zoi.optional()
                })
                |> Zoi.optional(),
              capabilities: @capabilities_schema |> Zoi.optional(),
              tags: Zoi.array(Zoi.string()) |> Zoi.optional(),
              deprecated: Zoi.boolean() |> Zoi.default(false),
              aliases: Zoi.array(Zoi.string()) |> Zoi.default([]),
              extra: Zoi.map() |> Zoi.optional()
            },
            coerce: true
          )

  @type t :: unquote(Zoi.type_spec(@schema))

  @enforce_keys Zoi.Struct.enforce_keys(@schema)
  defstruct Zoi.Struct.struct_fields(@schema)

  @doc "Returns the Zoi schema for Model"
  def schema, do: @schema

  @doc """
  Creates a new Model struct from a map, validating with Zoi schema.

  ## Examples

      iex> LLMDb.Model.new(%{id: "gpt-4", provider: :openai})
      {:ok, %LLMDb.Model{id: "gpt-4", provider: :openai}}

      iex> LLMDb.Model.new(%{})
      {:error, _validation_errors}
  """
  @spec new(map()) :: {:ok, t()} | {:error, term()}
  def new(attrs) when is_map(attrs) do
    Zoi.parse(@schema, attrs)
  end

  @doc """
  Creates a new Model struct from a map, raising on validation errors.

  ## Examples

      iex> LLMDb.Model.new!(%{id: "gpt-4", provider: :openai})
      %LLMDb.Model{id: "gpt-4", provider: :openai}
  """
  @spec new!(map()) :: t()
  def new!(attrs) when is_map(attrs) do
    case new(attrs) do
      {:ok, model} -> model
      {:error, reason} -> raise ArgumentError, "Invalid model: #{inspect(reason)}"
    end
  end
end
