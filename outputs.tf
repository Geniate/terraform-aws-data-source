output "table_arn" {
  description = "Dynamo db Table arn"
  value       = aws_dynamodb_table.data_soruce_table.arn
}

output "table_name" {
  description = "Name of the table"
  value       = aws_dynamodb_table.data_soruce_table.name
}

output "datasource_name" {
  description = "Name of the data source"
  value       = aws_appsync_datasource.data_source.name
}