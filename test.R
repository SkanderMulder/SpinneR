library(SpinneR)

print("Starting spinner test...")
with_spinner({
  print("Inside with_spinner, sleeping for 5 seconds...")
  Sys.sleep(5)
  print("Finished sleeping.")
})
print("Spinner test finished.")