let static =
  let open Dream in
  router [ get "/priv/**" @@ static "examples/priv/" ]
;;
