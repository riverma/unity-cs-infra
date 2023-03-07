resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.rest_api_name
  description = var.rest_api_description
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  body = data.template_file.api_template.rendered
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "api_gateway_cs_lambda_authorizer_uri" {
  name = var.ssm_param_api_gateway_function_cs_lambda_authorizer_uri
}

data "aws_ssm_parameter" "api_gateway_cs_lambda_authorizer_invoke_role_arn" {
  name = var.ssm_param_api_gateway_cs_lambda_authorizer_invoke_role_arn
}

data "aws_ssm_parameter" "api_gateway_integration_uads_dockstore_nlb_uri" {
  name = var.ssm_param_api_gateway_integration_uads_dockstore_nlb_uri
}

data "aws_ssm_parameter" "api_gateway_integration_uads_dockstore_link_2_vpc_link_id" {
  name = var.ssm_param_api_gateway_integration_uads_dockstore_link_2_vpc_link_id
}

data "aws_ssm_parameter" "api_gateway_integration_uds_granules_dapa_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_granules_dapa_function_name
}

data "aws_ssm_parameter" "api_gateway_integration_uds_collections_dapa_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_collections_dapa_function_name
}

data "aws_ssm_parameter" "api_gateway_integration_uds_collections_ingest_dapa_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_collections_ingest_dapa_function_name
}

data "aws_ssm_parameter" "api_gateway_integration_uds_collections_create_dapa_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_collections_create_dapa_function_name
}

module "api_gateway_integration_uds_auth_add_function_name"{
  source = "BardiaN/ssm-parameter-with-default-value/aws"
  version = "0.1.1"
  ssm_key = var.ssm_param_api_gateway_integration_uds_auth_add_function_name_function_name
  ssm_default_value = "dummy_uds_auth_add_function_name"
}

module "api_gateway_integration_uds_auth_list_function_name"{
  source = "BardiaN/ssm-parameter-with-default-value/aws"
  version = "0.1.1"
  ssm_key = var.ssm_param_api_gateway_integration_uds_auth_list_function_name_function_name
  ssm_default_value = "dummy_uds_auth_list_function_name"
}

module "api_gateway_integration_uds_auth_delete_function_name"{
  source = "BardiaN/ssm-parameter-with-default-value/aws"
  version = "0.1.1"
  ssm_key = var.ssm_param_api_gateway_integration_uds_auth_delete_function_name_function_name
  ssm_default_value = "dummy_uds_auth_delete_function_name"
}

module "api_gateway_integration_uds_setup_es_function_name"{
  source = "BardiaN/ssm-parameter-with-default-value/aws"
  version = "0.1.1"
  ssm_key = var.ssm_param_api_gateway_integration_uds_setup_es_function_name_function_name
  ssm_default_value = "dummy_uds_setup_es_function_name"
}
/*
data "aws_ssm_parameter" "api_gateway_integration_uds_auth_add_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_auth_add_function_name_function_name
}
data "aws_ssm_parameter" "api_gateway_integration_uds_auth_list_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_auth_list_function_name_function_name
}
data "aws_ssm_parameter" "api_gateway_integration_uds_auth_delete_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_auth_delete_function_name_function_name
}
data "aws_ssm_parameter" "api_gateway_integration_uds_setup_es_function_name" {
  name = var.ssm_param_api_gateway_integration_uds_setup_es_function_name_function_name
}
*/

data "template_file" "api_template" {
  template = file("./terraform-modules/api-gateway/unity-rest-api-gateway-oas30.yaml")

  vars = {
    csLambdaAuthorizerUri = data.aws_ssm_parameter.api_gateway_cs_lambda_authorizer_uri.value
    csLambdaAuthorizerInvokeRole = data.aws_ssm_parameter.api_gateway_cs_lambda_authorizer_invoke_role_arn.value
    uadsDockstoreNlbUri = data.aws_ssm_parameter.api_gateway_integration_uads_dockstore_nlb_uri.value
    uadsDockstoreLink2VpcLinkId = data.aws_ssm_parameter.api_gateway_integration_uads_dockstore_link_2_vpc_link_id.value
    udsGranulesDapaFunctionUri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${data.aws_ssm_parameter.api_gateway_integration_uds_granules_dapa_function_name.value}/invocations"
    udsCollectionsDapaFunctionUri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${data.aws_ssm_parameter.api_gateway_integration_uds_collections_dapa_function_name.value}/invocations"
    udsCollectionsIngestDapaFunctionUri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${data.aws_ssm_parameter.api_gateway_integration_uds_collections_ingest_dapa_function_name.value}/invocations"
    udsCollectionsCreateDapaFunctionUri = "arn:aws:apigateway:${data.aws_region.current.name}:lambda:path/2015-03-31/functions/arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:${data.aws_ssm_parameter.api_gateway_integration_uds_collections_create_dapa_function_name.value}/invocations"
  }
}

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  stage_name  = var.rest_api_stage

  variables = {
    adesWpstUrl      = "-",
    grqEsUrl         = "-",
    grqRestApiUrl    = "-",
    hysdsUiUrl       = "-",
    mozartEsUrl      = "-",
    mozartRestApiUrl = "-"
  }
}

resource "aws_ssm_parameter" "api_gateway_rest_api_id_parameter"{
  name       = format("/unity/%s/%s-%s/api-gateway/rest-api-id", var.rest_api_stage, var.namespace, var.counter)
  type       = "String"
  value      = "${aws_api_gateway_rest_api.rest_api.id}"
  overwrite  = true
  depends_on = [aws_api_gateway_rest_api.rest_api]
}

resource "aws_lambda_permission" "uds_granules_dapa_lambda_permission" {
  statement_id  = "AllowUDSGranulesDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.api_gateway_integration_uds_granules_dapa_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/GET/am-uds-dapa/collections/*/items"
}

resource "aws_lambda_permission" "uds_collection_dapa_lambda_permission" {
  statement_id  = "AllowUDSCollectionDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.api_gateway_integration_uds_collections_dapa_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/GET/am-uds-dapa/collections/*"
}

resource "aws_lambda_permission" "uds_collections_dapa_lambda_permission" {
  statement_id  = "AllowUDSCollectionsDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.api_gateway_integration_uds_collections_dapa_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/GET/am-uds-dapa/collections"
}

resource "aws_lambda_permission" "uds_collections_ingest_dapa_lambda_permission" {
  statement_id  = "AllowUDSCollectionsIngestDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.api_gateway_integration_uds_collections_ingest_dapa_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/PUT/am-uds-dapa/collections"
}



resource "aws_lambda_permission" "uds_setup_es_lambda_permission" {
  statement_id  = "AllowUDSCollectionsIngestDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.api_gateway_integration_uds_setup_es_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/PUT/am-uds-dapa/collections/auth/setup_es"
}

resource "aws_lambda_permission" "uds_auth_list_lambda_permission" {
  statement_id  = "AllowUDSCollectionsIngestDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.api_gateway_integration_uds_auth_list_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/GET/am-uds-dapa/collections/auth/admin"
}

resource "aws_lambda_permission" "uds_auth_delete_lambda_permission" {
  statement_id  = "AllowUDSCollectionsIngestDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.api_gateway_integration_uds_auth_delete_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/DELETE/am-uds-dapa/collections/auth/admin"
}

resource "aws_lambda_permission" "uds_collections_create_dapa_lambda_permission" {
  statement_id  = "AllowUDSCollectionsCreateDapaInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.aws_ssm_parameter.api_gateway_integration_uds_collections_create_dapa_function_name.value
  principal     = "apigateway.amazonaws.com"
  source_arn = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/POST/am-uds-dapa/collections"
}

output "url" {
  value = "${aws_api_gateway_deployment.api-gateway-deployment.invoke_url}/api"
}
