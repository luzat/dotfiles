source ~/.local/opt/pwndbg/gdbinit.py
source ~/.local/opt/splitmind/gdbinit.py

#set context-ghidra always

python
import splitmind
(splitmind.Mind()
  .tell_splitter(show_titles=True)
  .tell_splitter(set_title="Main")
  .right(display="backtrace", size="25%")
  .above(of="main", display="disasm", size="80%", banner="top")
  .show("code", on="disasm", banner="none")
  .right(cmd='tty; tail -f /dev/null', size="50%", clearing=False)
  .tell_splitter(set_title='Input / Output')
  .above(display="stack", size="75%")
  .above(display="legend", size="25")
  .show("regs", on="legend")
  .below(of="backtrace", cmd="ipython3", size="30%")
).build(nobanner=True)
end

#python
#import splitmind
#(splitmind.Mind()
#  .below(display="backtrace")
#  .right(display="stack", size="35%")
#  .right(display="regs", size="35%")
#  .right(of="main", display="disasm")
#  .show("legend", on="disasm")
#).build()
#end

