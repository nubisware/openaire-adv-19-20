# openaire-adv-19-20
OpenAIRE ADVANCE tender 2019-2020

To run fetcher just type 

``python3 src/fetcher/fetch_sources.py``

requests is required.
To change source edit the value of the variable index inside fetch_sources.py

To run the harvesting service an instance of basex is required.

``wget http://files.basex.org/releases/9.3.2/BaseX932.zip``

The copy the file ``src/xq/harvestservice.xqm`` to the webapp folder of basex and run ``bin/basexhttp &``.

Launch the GUI with ``bin/basexgui`` and use the toolbar to create a database called ``source{Index}``. The DB will contain the harvested records of source with index Index in their native XML form.
  
