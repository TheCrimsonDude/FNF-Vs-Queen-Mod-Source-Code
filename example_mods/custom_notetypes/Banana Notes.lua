function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Banana Notes' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'Banana');
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', false);
			end
		end
	end
end

function noteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'Banana Notes' then
		setProperty('health',0.5)
	end
end