import noah /  staticfiles 

export staticfiles

when defined(windows): 
  import noah / asynccontext
  export asynccontext
  
when defined(linux):
  import noah / beastcontext
  export beastcontext


