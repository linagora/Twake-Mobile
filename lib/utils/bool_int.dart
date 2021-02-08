int boolToInt(val) {
  // print('RENDERING $val');
  if (val is bool)
    return val ? 1 : 0;
  else
    return val ?? 0;
}

bool intToBool(val) {
  // print('RENDERING $val');
  return val == 0 ? false : true;
}
