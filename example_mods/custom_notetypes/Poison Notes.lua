function onCreate()

	for i = 0, getProperty('unspawnNotes.length')-1 do

		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Poison Notes' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'Poison');
			setPropertyFromGroup('unspawnNotes', i, 'hitHealth', '-0.5'); 
			setPropertyFromGroup('unspawnNotes', i, 'missHealth', '0.5');
			setPropertyFromGroup('unspawnNotes', i, 'hitCausesMiss', true);

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
			end
		end
	end

end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Poison Notes' then
	end
end

function noteMiss(id, noteData, noteType, isSustainNote)
	if noteType == 'Poison Notes' then
	end
end